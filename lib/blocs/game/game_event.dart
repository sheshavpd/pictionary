import 'package:equatable/equatable.dart';
import 'package:pictionary/models/Player.dart';
import 'package:pictionary/models/game_answer.dart';
import 'package:pictionary/models/game_details.dart';

abstract class GameEvent extends Equatable {
  const GameEvent();

  @override
  List<Object> get props => [];
}

class GameCreateRequested extends GameEvent {
  @override
  String toString() => 'GameCreateRequested';
}

class GameJoinRequested extends GameEvent {
  final String roomID;

  GameJoinRequested(this.roomID);

  @override
  String toString() => 'GameJoinRequested';

  @override
  List<Object> get props => [roomID];
}

class GameExited extends GameEvent {
  @override
  String toString() => 'GameExited';
}

class GameUserJoined extends GameEvent {
  final Player newPlayer;
  final String gameRoomID;

  GameUserJoined(this.newPlayer, this.gameRoomID);

  @override
  String toString() => 'GameUserJoined';

  @override
  List<Object> get props => [newPlayer, gameRoomID];
}

class GameUserLeft extends GameEvent {
  final String playerUID;
  final String gameRoomID;

  GameUserLeft(this.playerUID, this.gameRoomID);

  @override
  String toString() => 'GameUserJoined';

  @override
  List<Object> get props => [playerUID, gameRoomID];
}

class GameHintReceived extends GameEvent {
  final String hint;

  GameHintReceived(this.hint);

  @override
  String toString() => 'GameHintReceived';

  @override
  List<Object> get props => [hint];
}

class GameAnswerReceived extends GameEvent {
  final GameAnswer gameAnswer;

  GameAnswerReceived(this.gameAnswer);

  @override
  String toString() => 'GameAnswerReceived';

  @override
  List<Object> get props => [gameAnswer];
}

class GameAnswerSimilar extends GameEvent {
  final int similarity;
  final String answer;

  GameAnswerSimilar({this.answer, this.similarity});

  @override
  String toString() => 'GameAnswerSimilar';

  @override
  List<Object> get props => [similarity, answer];
}

class GameChoosing extends GameEvent {
  final GameDetails gameDetails;
  final List<String> words;

  GameChoosing({this.gameDetails, this.words});

  @override
  String toString() => 'GameChoosing';

  @override
  List<Object> get props => [this.gameDetails, this.words];
}

class GameDrawingStarted extends GameEvent {
  final GameDetails gameDetails;
  final String hint;

  GameDrawingStarted({this.gameDetails, this.hint});

  @override
  String toString() => 'GameAnswerSimilar';

  @override
  List<Object> get props => [hint, gameDetails];
}

class GameDrawingComplete extends GameEvent {
  final Map playerScores;
  final String lastWord;

  GameDrawingComplete({this.playerScores, this.lastWord});

  @override
  String toString() => 'GameAnswerSimilar';

  @override
  List<Object> get props => [playerScores, lastWord];
}

class GameEnded extends GameEvent {
  final Map playerScores;
  final int timeout;

  GameEnded({this.playerScores, this.timeout});

  @override
  String toString() => 'GameEnded';

  @override
  List<Object> get props => [playerScores, timeout];
}

class ChoseWord extends GameEvent {
  final String word;

  ChoseWord(this.word);

  @override
  String toString() => 'ChoseWord';

  @override
  List<Object> get props => [word];
}

class GuessSubmitted extends GameEvent {
  final String word;

  GuessSubmitted(this.word);

  @override
  String toString() => 'GuessSubmitted';

  @override
  List<Object> get props => [word];
}

class GameTest extends GameEvent {
  @override
  String toString() => 'GameTest';
}
