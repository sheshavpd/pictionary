import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/enums.dart';

class AudioState extends Equatable {
  final bool audioEnabledInGame;
  final bool audioRecording;
  final bool speakerEnabled;
  final Map<String, RTCIceConnectionState> peerAudioStatus;
  AudioState({ @required this.audioEnabledInGame, @required  this.audioRecording, @required  this.speakerEnabled, @required this.peerAudioStatus});
  @override
  String toString() => 'AudioState';

  AudioState copyWith({bool audioEnabledInGame, bool audioRecording, bool speakerEnabled, Map peerAudioStatus}){
      return AudioState(
        audioEnabledInGame: audioEnabledInGame ?? this.audioEnabledInGame,
        audioRecording: audioRecording ?? this.audioRecording,
        speakerEnabled: speakerEnabled ?? this.speakerEnabled,
        peerAudioStatus: peerAudioStatus ?? this.peerAudioStatus,
      );
  }
  @override
  List<Object> get props => [this.audioEnabledInGame, this.audioRecording, this.speakerEnabled, this.peerAudioStatus];
}
