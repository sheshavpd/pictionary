import 'package:equatable/equatable.dart';

class AudioState extends Equatable {
  final bool audioEnabledInGame;
  final bool audioRecording;
  final bool speakerEnabled;
  const AudioState({this.audioEnabledInGame, this.audioRecording, this.speakerEnabled});
  @override
  String toString() => 'AudioState';

  AudioState copyWith({bool audioEnabledInGame, bool audioRecording, bool speakerEnabled}){
      return AudioState(
        audioEnabledInGame: audioEnabledInGame ?? this.audioEnabledInGame,
        audioRecording: audioRecording ?? this.audioRecording,
        speakerEnabled: speakerEnabled ?? this.speakerEnabled,
      );
  }
  @override
  List<Object> get props => [this.audioEnabledInGame, this.audioRecording, this.speakerEnabled];
}
