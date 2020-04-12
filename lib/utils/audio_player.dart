import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';

class GameSounds {
  static AudioCache _audioCache = new AudioCache(prefix: "sounds/");
  static AudioCache _audioCacheFixed = new AudioCache(prefix: "sounds/", fixedPlayer: AudioPlayer(mode: PlayerMode.LOW_LATENCY));

  static final GameSounds _gameSounds = GameSounds._internal();

  factory GameSounds() {
    return _gameSounds;
  }

  GameSounds._internal();

  void playUserJoined() {
    const audioPath = "enter_game.mp3";
    _audioCache.play(audioPath);
  }

  void playUserLeft() {
    const audioPath = "exit_game.mp3";
    _audioCache.play(audioPath);
  }

  void playClick() {
    const audioPath = "click.mp3";
    _audioCacheFixed.play(audioPath);
  }

  void playRoundComplete() {
    const audioPath = "draw_complete.mp3";
    _audioCache.play(audioPath);
  }

  void playGameFinish() {
    const audioPath = "game_finish.mp3";
    _audioCache.play(audioPath);
  }

  void playRightGuess() {
    const audioPath = "right_guess.mp3";
    _audioCache.play(audioPath);
  }
}
