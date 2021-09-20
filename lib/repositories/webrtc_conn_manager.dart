import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/rtc_peerconnection.dart';
import 'package:flutter_webrtc/webrtc.dart';
import 'package:pictionary/blocs/game/game_sv_events.dart';
import 'package:pictionary/common/app_logger.dart';
import 'package:pictionary/repositories/AppSocket.dart';
import 'package:pictionary/repositories/mediastream_manager.dart';
import 'package:rxdart/subjects.dart';

const _WEBRTC_TAG = "[WebRTC_DEBUG]";

class RTCIceStateMsg {
  final String uid;
  final RTCIceConnectionState iceConnectionState;

  RTCIceStateMsg(this.uid, this.iceConnectionState);
}

class WebRTCConnectionManager {
  final LocalMediaStreamManager _localMediaStreamManager =
      LocalMediaStreamManager();
  StreamSubscription<String> _socketMsgSubs;
  final Map<String, RemotePeerAudioConnection> connections = {};
  final Map<String, Function(Map msg)> _signalHandlers = {};
  final userIceStateStream = PublishSubject<RTCIceStateMsg>();
  bool _speakerEnabled = true;

  static WebRTCConnectionManager _webRTCConnectionManager;

  factory WebRTCConnectionManager() {
    if (_webRTCConnectionManager == null) {
      _webRTCConnectionManager = WebRTCConnectionManager._internal();
    }
    return _webRTCConnectionManager;
  }

  WebRTCConnectionManager._internal() {
    _initSignalHandlers();
    _socketMsgSubs = AppSocket().message.listen(_onRemoteSignal);
  }

  void _initSignalHandlers() {

    // implemented as per https://developer.mozilla.org/en-US/docs/Web/API/WebRTC_API/Perfect_negotiation
    final onOfferOrAnswer = (signal) async {
      final uid = signal['uid'];
      if (uid == null) return;
      if (!connections.containsKey(uid)) {
        connections[uid] = await RemotePeerAudioConnection.fromOffer(uid,
            enabled: _speakerEnabled);
      }
      final rpc = connections[uid];
      alog.d('$_WEBRTC_TAG Received new ${signal['type']}');
      final offerCollision = signal['type'] == PeerConnConstants.OFFER &&
          (rpc.makingOffer ||
              rpc._peerConnection.signalingState !=
                  RTCSignalingState.RTCSignalingStateStable);
      rpc.ignoreOffer = rpc.impolite && offerCollision;
      if (rpc.ignoreOffer) {
        alog.d('$_WEBRTC_TAG  Ignored ${signal['type']}');
        return;
      }
      if (signal['type'] == PeerConnConstants.OFFER) {
        rpc._handleOffer(RTCSessionDescription(
            signal['offer']['sdp'], signal['offer']['type']));
      } else {
        connections[signal['uid']].handleAnswer(RTCSessionDescription(
            signal['answer']['sdp'], signal['answer']['type']));
      }
    };
    _signalHandlers[PeerConnConstants.OFFER] = onOfferOrAnswer;
    _signalHandlers[PeerConnConstants.ANSWER] = onOfferOrAnswer;
    _signalHandlers[PeerConnConstants.CANDIDATE] = (signal) {
      connections[signal['uid']]?._handleCandidate(RTCIceCandidate(
          signal['candidate']['candidate'],
          signal['candidate']['sdpMid'],
          signal['candidate']['sdpMLineIndex']));
    };
  }

  void _onRemoteSignal(String msg) {
    try {
      final signal = json.decode(msg);
      if (_signalHandlers.containsKey(signal['type'])) {
        _signalHandlers[signal['type']](signal);
      }
    } catch (e) {
      alog.e('$_WEBRTC_TAG  $e');
    }
  }

  set speakerEnabled(bool enabled) {
    _speakerEnabled = enabled;
    for (final conn in connections.values) {
      conn.enabled = enabled;
    }
  }

  void connectPeer(String uid) async {
    if (connections.containsKey(uid)) {
      await connections[uid].dispose();
      return;
    }
    connections[uid] =
        await RemotePeerAudioConnection.initiate(uid, enabled: _speakerEnabled);
  }

  Future<void> disconnectPeer(String uid) async {
    if (connections.containsKey(uid)) {
      await connections[uid].dispose();
      connections.remove(uid);
      return;
    }
  }

  static disconnectIfInstanceExists(String uid) {
    if(_webRTCConnectionManager != null)
    _webRTCConnectionManager.disconnectPeer(uid);
  }

  static nofityIfInstanceExists(RTCIceStateMsg iceStateMsg) {
    if(_webRTCConnectionManager != null)
      _webRTCConnectionManager.userIceStateStream.add(iceStateMsg);
  }

  Future<void> dispose() async {
    _webRTCConnectionManager = null;
    _socketMsgSubs?.cancel();
    for (final conn in connections.values) {
      await conn.dispose();
    }
    userIceStateStream.close();
    await _localMediaStreamManager.disposeLocalAudioStream();
  }
}

// implemented as per https://developer.mozilla.org/en-US/docs/Web/API/WebRTC_API/Perfect_negotiation
class RemotePeerAudioConnection {
  final RTCVideoRenderer remoteRenderer;
  final String userID;
  final RTCPeerConnection _peerConnection;
  bool _enabled = true;
  bool ignoreOffer = false;
  final bool
      impolite; //If this connection was initiated by me, or other. (initiator = true, means initiated by me.)

  RemotePeerAudioConnection._(this._peerConnection, this.userID,
      {this.impolite = false,
      @required this.remoteRenderer,
      @required bool enabled})
      : _enabled = enabled {
    _peerConnection.onAddTrack = _onTrack;
    _peerConnection.onRenegotiationNeeded = _onRenegotiationNeeded;
    _peerConnection.onSignalingState = _onSignalingState;
    _peerConnection.onIceGatheringState = _onIceGatheringState;
    _peerConnection.onIceConnectionState = _onIceConnectionState;
    _peerConnection.onRemoveStream = _onRemoveStream;
    alog.d(
        "$_WEBRTC_TAG $userID  Created peerConnection object. Initiator : $impolite}");
  }

  set enabled(bool enabled) {
    _enabled = enabled;
    if (_peerConnection != null && _peerConnection.getRemoteStreams() != null) {
      _peerConnection.getRemoteStreams().forEach((rStream) {
        if (rStream.getAudioTracks() != null) {
          rStream.getAudioTracks().forEach((audioTrack) {
            audioTrack.enabled = _enabled;
          });
        }
      });
    }
  }

  static final Map<String, dynamic> _configuration = {
    "iceServers": [
      {"url": "stun:quarantinegames.in:3478"},
      {"url": "stun:stun.l.google.com:19302"},
    ]
  };

  static Future<RemotePeerAudioConnection> initiate(String userID,
      {@required bool enabled}) async {
    final remoteRenderer = RTCVideoRenderer();
    await remoteRenderer.initialize();
    RTCPeerConnection _peerConnection =
        await createPeerConnection(_configuration, {});
    await _peerConnection
        .addStream(await LocalMediaStreamManager().getLocalAudioStream());
    final rpc = RemotePeerAudioConnection._(_peerConnection, userID,
        remoteRenderer: remoteRenderer, impolite: true, enabled: enabled);
    _peerConnection.onIceCandidate = rpc._onCandidate;
    //await rpc._createOffer(); //offer created in 'negotiationneeded' event. see https://developer.mozilla.org/en-US/docs/Web/API/WebRTC_API/Signaling_and_video_calling for the flow.
    return rpc;
  }

  static Future<RemotePeerAudioConnection> fromOffer(String userID,
      {@required bool enabled}) async {
    final remoteRenderer = RTCVideoRenderer();
    await remoteRenderer.initialize();
    RTCPeerConnection _peerConnection =
        await createPeerConnection(_configuration, {});
    await _peerConnection
        .addStream(await LocalMediaStreamManager().getLocalAudioStream());
    final rpc = RemotePeerAudioConnection._(_peerConnection, userID,
        remoteRenderer: remoteRenderer, impolite: false, enabled: enabled);
    _peerConnection.onIceCandidate = rpc._onCandidate;
    return rpc;
  }

  _createOffer({@required bool iceRestart}) async {
    final Map<String, dynamic> offer_sdp_constraints = {
      "mandatory": {
        "OfferToReceiveAudio": true,
        "OfferToReceiveVideo": false,
      },
      "iceRestart": iceRestart,
      "optional": [],
    };
    RTCSessionDescription offer =
        await _peerConnection.createOffer(offer_sdp_constraints);
    _peerConnection.setLocalDescription(offer);
    AppSocket().sendMessage(json.encode({
      'type': PeerConnConstants.OFFER,
      'uid': userID,
      'offer': offer.toMap(),
    }));
    alog.d('$_WEBRTC_TAG  created offer. Sent over.');
  }

  _handleOffer(RTCSessionDescription offer) async {
    final Map<String, dynamic> offer_sdp_constraints = {
      "mandatory": {
        "OfferToReceiveAudio": true,
        "OfferToReceiveVideo": false,
      },
      "optional": [],
    };
    _peerConnection.setRemoteDescription(offer);

    //create an answer to an offer
    RTCSessionDescription answer =
        await _peerConnection.createAnswer(offer_sdp_constraints);
    _peerConnection.setLocalDescription(answer);
    AppSocket().sendMessage(json.encode({
      'type': PeerConnConstants.ANSWER,
      'uid': userID,
      'answer': answer.toMap()
    }));
    alog.d('$_WEBRTC_TAG  handled offer. Sent answer');
  }

  handleAnswer(RTCSessionDescription answer) {
    alog.d('$_WEBRTC_TAG  handled answer. Remote description set');
    _peerConnection.setRemoteDescription(answer);
  }

  _onSignalingState(RTCSignalingState state) {
    alog.d('$_WEBRTC_TAG $userID  $state');
    if(state == RTCSignalingState.RTCSignalingStateClosed) {
      WebRTCConnectionManager.disconnectIfInstanceExists(userID); // Because instance might be closed when this event happens.
    }
  }

  _onIceGatheringState(RTCIceGatheringState state) {
    alog.d('$_WEBRTC_TAG $userID  $state');
  }

  _onIceConnectionState(RTCIceConnectionState state) async {
    WebRTCConnectionManager.nofityIfInstanceExists(RTCIceStateMsg(userID, state)); // Because instance might be closed when this event happens.
    if (state == RTCIceConnectionState.RTCIceConnectionStateFailed) {
      try {
        await _createOffer(iceRestart: true);
      } catch (e) {
        alog.e('$_WEBRTC_TAG $userID  $e');
      }
    }
    alog.d('$_WEBRTC_TAG $userID  $state');
  }

  _onTrack(MediaStream mediaStream, MediaStreamTrack mediaStreamTrack) {
    remoteRenderer.srcObject = mediaStream;
    enabled = _enabled; //Mute speaker, if state is muted.
  }

  /*_onAddStream(MediaStream stream) {
    //alog.d('addStream: ' + stream.id);
    remoteRenderer.srcObject = stream;
  }*/

  _onRemoveStream(MediaStream stream) {
    remoteRenderer.srcObject = null;
  }

  _handleCandidate(RTCIceCandidate candidate) async {
    try {
      await _peerConnection.addCandidate(candidate);
    } catch (e) {
      if (!ignoreOffer) throw e;
    }
  }

  _onCandidate(RTCIceCandidate candidate) async {
    alog.d('$_WEBRTC_TAG $userID  onCandidate: ' + candidate.candidate);
    AppSocket().sendMessage(json.encode({
      'type': PeerConnConstants.CANDIDATE,
      'uid': userID,
      'candidate': candidate.toMap()
    }));
  }

  //TODO: Implement id based negotiation between peers.
  bool makingOffer =
      false; //Useful to implement perfect negotiation (https://developer.mozilla.org/en-US/docs/Web/API/WebRTC_API/Perfect_negotiation)
  _onRenegotiationNeeded() async {
    //TODO: Shouldn't return for being a polite peer. But, somehow this seems to resolve negotiation.
    // Since this application doesn't need renegotiation after user switches between
    // different networks (because game quits when that happens), this should be fine.
    if (!impolite || makingOffer) {
      return; // Workaround for Chrome webrtc bundle (Happens only in chrome): skip nested negotiations
    }
    alog.d('$_WEBRTC_TAG $userID  RenegotiationNeeded');
    makingOffer = true;
    try {
      await _createOffer(iceRestart: false);
    } catch (e) {
      alog.e('$_WEBRTC_TAG $userID  $e');
    }
    makingOffer = false;
  }

  Future<void> dispose() async {
    try {
      await _peerConnection.close();
    } catch (e) {}
    try {
      await remoteRenderer?.dispose();
    } catch (e) {}
  }
}
