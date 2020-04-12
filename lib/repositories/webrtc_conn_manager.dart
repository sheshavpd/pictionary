import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/rtc_peerconnection.dart';
import 'package:flutter_webrtc/webrtc.dart';
import 'package:pictionary/blocs/game/game_sv_events.dart';
import 'package:pictionary/common/app_logger.dart';
import 'package:pictionary/repositories/AppSocket.dart';
import 'package:pictionary/repositories/mediastream_manager.dart';

const _WEBRTC_TAG = "[WebRTC_DEBUG]";
class WebRTCConnectionManager {
  final LocalMediaStreamManager _localMediaStreamManager =
      LocalMediaStreamManager();
  StreamSubscription<String> _socketMsgSubs;
  final Map<String, RemotePeerAudioConnection> connections = {};
  final Map<String, Function(Map msg)> _signalHandlers = {};
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
    _signalHandlers[PeerConnConstants.OFFER] = (signal) async {
      final uid = signal['uid'];
      if (uid == null) return;
      if (connections.containsKey(uid)) {
        connections[uid].dispose();
      }
      connections[uid] = await RemotePeerAudioConnection.fromOffer(
          RTCSessionDescription(
              signal['offer']['sdp'], signal['offer']['type']),
          uid,
          enabled: _speakerEnabled);
    };
    _signalHandlers[PeerConnConstants.ANSWER] = (signal) {
      if (connections[signal['uid']] == null ||
          !connections[signal['uid']].initiator) return;
      connections[signal['uid']].handleAnswer(RTCSessionDescription(
          signal['answer']['sdp'], signal['answer']['type']));
    };
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
      connections[uid].dispose();
      return;
    }
    connections[uid] =
        await RemotePeerAudioConnection.initiate(uid, enabled: _speakerEnabled);
  }

  void disconnectPeer(String uid) async {
    if (connections.containsKey(uid)) {
      connections[uid].dispose();
      connections.remove(uid);
      return;
    }
  }

  Future<void> dispose() async {
    _socketMsgSubs?.cancel();
    for (final conn in connections.values) {
      await conn.dispose();
    }
    await _localMediaStreamManager.disposeLocalAudioStream();
    _webRTCConnectionManager = null;
  }
}

class RemotePeerAudioConnection {
  final remoteRenderer = RTCVideoRenderer();
  final String userID;
  final RTCPeerConnection _peerConnection;
  bool _enabled = true;
  final bool
      initiator; //If this connection was initiated by me, or other. (initiator = true, means initiated by me.)

  RemotePeerAudioConnection._(this._peerConnection, this.userID,
      {this.initiator = false, @required bool enabled})
      : _enabled = enabled {
    _peerConnection.onSignalingState = _onSignalingState;
    _peerConnection.onIceGatheringState = _onIceGatheringState;
    _peerConnection.onIceConnectionState = _onIceConnectionState;
    _peerConnection.onRemoveStream = _onRemoveStream;
    _peerConnection.onRenegotiationNeeded = _onRenegotiationNeeded;
    alog.d("$_WEBRTC_TAG $userID  Created peerConnection object. Initiator : $initiator}");
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
    RTCPeerConnection _peerConnection =
        await createPeerConnection(_configuration, {});
    final rpc = RemotePeerAudioConnection._(_peerConnection, userID,
        initiator: true, enabled: enabled);
    await rpc.remoteRenderer.initialize();
    await _peerConnection
        .addStream(await LocalMediaStreamManager().getLocalAudioStream());
    _peerConnection.onAddStream = rpc._onAddStream;
    _peerConnection.onIceCandidate = rpc._onCandidate;
    //await rpc._createOffer(); //offer created in 'negotiationneeded' event. see https://developer.mozilla.org/en-US/docs/Web/API/WebRTC_API/Signaling_and_video_calling for the flow.
    return rpc;
  }

  static Future<RemotePeerAudioConnection> fromOffer(
      RTCSessionDescription offer, String userID,
      {@required bool enabled}) async {
    RTCPeerConnection _peerConnection =
        await createPeerConnection(_configuration, {});
    final rpc = RemotePeerAudioConnection._(_peerConnection, userID,
        initiator: false, enabled: enabled);
    await rpc.remoteRenderer.initialize();
    await _peerConnection
        .addStream(await LocalMediaStreamManager().getLocalAudioStream());
    _peerConnection.onAddStream = rpc._onAddStream;
    _peerConnection.onIceCandidate = rpc._onCandidate;
    rpc._handleOffer(offer);
    return rpc;
  }

  _createOffer({@required bool iceRestart}) async {
    final Map<String, dynamic> offer_sdp_constraints = {
      "mandatory": {
        "OfferToReceiveAudio": true,
        "OfferToReceiveVideo": false,
      },
      "iceRestart":iceRestart,
      "optional": [],
    };
    RTCSessionDescription offer =
        await _peerConnection.createOffer(offer_sdp_constraints);
    _peerConnection.setLocalDescription(offer);
    AppSocket().sendMessage(json.encode({
      'type': PeerConnConstants.OFFER,
      'uid': userID,
      'offer': offer.toMap()
    }));
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
  }

  handleAnswer(RTCSessionDescription answer) {
    _peerConnection.setRemoteDescription(answer);
  }

  _onSignalingState(RTCSignalingState state) {
    alog.d('$_WEBRTC_TAG $userID  $state');
  }

  _onIceGatheringState(RTCIceGatheringState state) {
    alog.d('$_WEBRTC_TAG $userID  $state');
  }

  _onIceConnectionState(RTCIceConnectionState state) async{
    if(state == RTCIceConnectionState.RTCIceConnectionStateFailed && initiator) {
      try {
        await _createOffer(iceRestart: true);
      } catch (e) {;
      alog.e('$_WEBRTC_TAG $userID  $e');
      }
    }
    alog.d('$_WEBRTC_TAG $userID  $state');
  }

  _onAddStream(MediaStream stream) {
    //alog.d('addStream: ' + stream.id);
    remoteRenderer.srcObject = stream;
    enabled = _enabled; //Mute speaker, if state is muted.
  }

  _onRemoveStream(MediaStream stream) {
    remoteRenderer.srcObject = null;
  }

  _handleCandidate(RTCIceCandidate candidate) {
    _peerConnection.addCandidate(candidate);
  }

  _onCandidate(RTCIceCandidate candidate) async {
    alog.d('$_WEBRTC_TAG $userID  onCandidate: ' + candidate.candidate);
    AppSocket().sendMessage(json.encode({
      'type': PeerConnConstants.CANDIDATE,
      'uid': userID,
      'candidate': candidate.toMap()
    }));
  }

  bool _isNegotiating =
      false; // Workaround for Chrome webrtc bundle (Happens only in chrome): skip nested negotiations
  _onRenegotiationNeeded() async {
    alog.d('$_WEBRTC_TAG $userID  RenegotiationNeeded');
    if (_isNegotiating || !initiator) {
      return;
    }
    _isNegotiating = true;
    try {
      await _createOffer(iceRestart: false);
    } catch (e) {
     alog.e('$_WEBRTC_TAG $userID  $e');
    }
    _isNegotiating = false;
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
