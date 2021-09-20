import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter_webrtc/enums.dart';
import 'package:pictionary/blocs/game/game.dart';
import 'package:pictionary/common/app_logger.dart';
import 'package:pictionary/repositories/mediastream_manager.dart';
import 'package:pictionary/repositories/webrtc_conn_manager.dart';

import 'audio.dart';

class AudioBloc extends Bloc<AudioEvent, AudioState> {
  WebRTCConnectionManager _webRTCConnectionManager;
  StreamSubscription<RTCIceStateMsg> _userAudioStateSub;
  final GameBloc _gameBloc;

  AudioBloc(this._gameBloc);

  @override
  AudioState get initialState => AudioState(
      audioEnabledInGame: false, audioRecording: false, speakerEnabled: true, peerAudioStatus: {});

  @override
  Stream<AudioState> mapEventToState(
    AudioEvent event,
  ) async* {
    if (event is AudioSetInGameAudioEnabled) {
      if (event.enabled) {
        _webRTCConnectionManager = WebRTCConnectionManager();
        _userAudioStateSub = _webRTCConnectionManager.userIceStateStream.listen((stateMsg){
          alog.d('WebRTC_DEBUG ${stateMsg.uid} ${stateMsg.iceConnectionState}');
          add(AudioUserConStatusChanged(stateMsg));
        });
        _webRTCConnectionManager.speakerEnabled = state.speakerEnabled;
        LocalMediaStreamManager().muted = !state.audioRecording;
        //final players = (_gameBloc.state as GamePlaying).gameDetails.players;
        //If there are only 2 players, let the second player initiate the peer connection. (Helpful when both players joined just now.) (Player joined recently will be in the first index).
        /*alog.d('[WebRTC_DEBUG] 0th: ${players[0].uid} me: ${_gameBloc.user.uid}');
        if (players.length > 2 || players[0].uid == _gameBloc.user.uid) {
          players?.forEach((p) {
            if (p.uid != _gameBloc.user.uid)
              _webRTCConnectionManager.connectPeer(p.uid);
          });
        }*/
      } else {
        if (_webRTCConnectionManager != null) {
          await _webRTCConnectionManager.dispose();
          _webRTCConnectionManager = null;
        }
      }
      yield state.copyWith(audioEnabledInGame: event.enabled);
    }
    if (event is AudioSetSpeaker) {
      if (_webRTCConnectionManager != null) {
        _webRTCConnectionManager.speakerEnabled = event.enabled;
      }
      BotToast.showText(
          text:
              "Audio[Beta]: ${event.enabled ? 'Enabled' : 'Disabled'} speaker",
          duration: Duration(seconds: 2));
      yield state.copyWith(speakerEnabled: event.enabled);
    }

    if (event is AudioSetMicrophone) {
      if (_webRTCConnectionManager != null) {
        LocalMediaStreamManager().muted = !event.enabled;
      }
      BotToast.showText(
          text:
              "Audio[Beta]: ${event.enabled ? 'Enabled' : 'Disabled'} microphone",
          duration: Duration(seconds: 2));
      yield state.copyWith(audioRecording: event.enabled);
    }

    if (event is AudioUserConStatusChanged) {
      final newAudioStatusMap = Map<String, RTCIceConnectionState>.from(state.peerAudioStatus);
      newAudioStatusMap[event.stateMsg.uid] = event.stateMsg.iceConnectionState;
      yield state.copyWith(peerAudioStatus: newAudioStatusMap);
    }

    if (event is AudioRestartUserVoiceComm) {
      if (_webRTCConnectionManager != null) {
        await _webRTCConnectionManager.disconnectPeer(event.userID);
        _webRTCConnectionManager.connectPeer(event.userID);
      }
    }
  }

  @override
  Future<void> close() {
    if (_webRTCConnectionManager != null) {
      _webRTCConnectionManager.dispose();
    }
    _userAudioStateSub?.cancel();
    return super.close();
  }
}
