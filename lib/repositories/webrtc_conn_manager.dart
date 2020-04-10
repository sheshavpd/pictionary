import 'dart:async';
import 'dart:convert';

import 'package:flutter_webrtc/rtc_peerconnection.dart';
import 'package:flutter_webrtc/webrtc.dart';
import 'package:pictionary/blocs/game/game_sv_events.dart';
import 'package:pictionary/common/app_logger.dart';
import 'package:pictionary/repositories/AppSocket.dart';
import 'package:pictionary/repositories/mediastream_manager.dart';

class WebRTCConnectionManager {
  final LocalMediaStreamManager _localMediaStreamManager =
      LocalMediaStreamManager();
  StreamSubscription<String> _socketMsgSubs;
  final Map<String, RemotePeerAudioConnection> connections = {};
  final Map<String, Function(Map msg)> _signalHandlers = {};


  static WebRTCConnectionManager _webRTCConnectionManager;

  factory WebRTCConnectionManager() {
    if(_webRTCConnectionManager == null) {
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
          uid);
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
      print(e);
    }
  }

  void connectPeer(String uid) async {
    if (connections.containsKey(uid)) {
      connections[uid].dispose();
      return;
    }
    connections[uid] = await RemotePeerAudioConnection.initiate(uid);
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
  final bool
      initiator; //If this connection was initiated by me, or other. (initiator = true, means initiated by me.)

  RemotePeerAudioConnection._(this._peerConnection, this.userID,
      {this.initiator = false}) {
    _peerConnection.onSignalingState = _onSignalingState;
    _peerConnection.onIceGatheringState = _onIceGatheringState;
    _peerConnection.onIceConnectionState = _onIceConnectionState;
    _peerConnection.onRemoveStream = _onRemoveStream;
    _peerConnection.onRenegotiationNeeded = _onRenegotiationNeeded;
    alog.d("Created peerConnection object. Initiator : $initiator}");
  }

  static final Map<String, dynamic> _configuration = {
    "iceServers": [
      {"url": "stun:stun.l.google.com:19302"},
    ]
  };

  static Future<RemotePeerAudioConnection> initiate(String userID) async {
    RTCPeerConnection _peerConnection =
        await createPeerConnection(_configuration, {});
    final rpc =
        RemotePeerAudioConnection._(_peerConnection, userID, initiator: true);
    await rpc.remoteRenderer.initialize();
    await _peerConnection
        .addStream(await LocalMediaStreamManager().getLocalAudioStream());
    _peerConnection.onAddStream = rpc._onAddStream;
    _peerConnection.onIceCandidate = rpc._onCandidate;
    await rpc._createOffer();
    return rpc;
  }

  static Future<RemotePeerAudioConnection> fromOffer(
      RTCSessionDescription offer, String userID) async {
    RTCPeerConnection _peerConnection =
        await createPeerConnection(_configuration, {});
    final rpc =
        RemotePeerAudioConnection._(_peerConnection, userID, initiator: false);
    await rpc.remoteRenderer.initialize();
    await _peerConnection
        .addStream(await LocalMediaStreamManager().getLocalAudioStream());
    _peerConnection.onAddStream = rpc._onAddStream;
    _peerConnection.onIceCandidate = rpc._onCandidate;
    rpc._handleOffer(offer);
    return rpc;
  }

  _createOffer() async {
    final Map<String, dynamic> offer_sdp_constraints = {
      "mandatory": {
        "OfferToReceiveAudio": true,
        "OfferToReceiveVideo": false,
      },
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
    alog.d(state);
  }

  _onIceGatheringState(RTCIceGatheringState state) {
    alog.d(state);
  }

  _onIceConnectionState(RTCIceConnectionState state) {
    alog.d(state);
  }

  _onAddStream(MediaStream stream) {
    //alog.d('addStream: ' + stream.id);
    remoteRenderer.srcObject = stream;
  }

  _onRemoveStream(MediaStream stream) {
    remoteRenderer.srcObject = null;
  }

  _handleCandidate(RTCIceCandidate candidate) {
    _peerConnection.addCandidate(candidate);
  }

  _onCandidate(RTCIceCandidate candidate) async {
    alog.d('onCandidate: ' + candidate.candidate);
    AppSocket().sendMessage(json.encode({
      'type': PeerConnConstants.CANDIDATE,
      'uid': userID,
      'candidate': candidate.toMap()
    }));
  }

  bool _isNegotiating =
      false; // Workaround for Chrome webrtc bundle (Happens only in chrome): skip nested negotiations
  _onRenegotiationNeeded() async {
    alog.d('RenegotiationNeeded');
    /*if (_isNegotiating || !initiator) {
      return;
    }
    _isNegotiating = true;
    try {
      await _createOffer();
    } catch (e) {
     print(e);
    }
    _isNegotiating = false;*/
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
