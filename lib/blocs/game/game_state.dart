import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:pictionary/common/pretty_print.dart';
import 'package:pictionary/models/game_answer.dart';
import 'package:pictionary/models/game_details.dart';

abstract class GameState extends Equatable {
  @override
  List<Object> get props => [];

}

class GameNotPlaying extends GameState {
  @override
  String toString() => 'GameNotPlaying';
}

class GameCreating extends GameState {
  @override
  String toString() => 'GameCreating';
}

class GameJoining extends GameState {
  @override
  String toString() => 'GameJoining';
}

class GameCreateFailed extends GameState {
  final String failReason;

  GameCreateFailed(this.failReason);

  @override
  String toString() => 'GameCreateFailed';

  List<Object> get props => [failReason];
}

class GamePlaying extends GameState {
  final List<GameAnswer> answers;
  final List<String> wordsToChoose;
  final String gameRoomID;
  final String gameRoomNick;
  final String hint;
  final String lastWord;
  final GameDetails gameDetails;

  GamePlaying(
      {this.gameDetails,
      this.wordsToChoose,
      this.gameRoomID,
      this.gameRoomNick,
      this.hint,
      this.lastWord,
      this.answers});

  GamePlaying copyWith(
      {GameDetails gameDetails,
      List<GameAnswer> answers,
      List<String> wordsToChoose,
      String gameRoomID,
      String gameRoomNick,
      String hint,
      String lastWord}) {
    return GamePlaying(
        gameDetails: gameDetails ?? this.gameDetails,
        answers: answers ?? this.answers,
        wordsToChoose: wordsToChoose ?? this.wordsToChoose,
        gameRoomID: gameRoomID ?? this.gameRoomID,
        gameRoomNick: gameRoomNick ?? this.gameRoomNick,
        hint: hint ?? this.hint,
        lastWord: lastWord ?? this.lastWord);
  }

  @override
  List<Object> get props => [
        this.gameRoomID,
        gameRoomNick,
        hint,
        lastWord,
        wordsToChoose,
        gameDetails,
        answers,
      ];


  @override
  String toString() {
    return prettyPrint({
      'gameRoomID': this.gameRoomID,
      'gameRoomNick': gameRoomNick,
      'hint': hint,
      'lastWord': lastWord,
      'wordsToChoose': wordsToChoose?.toString() ?? 'N/A',
      'gameDetails':  gameDetails?.toString() ?? 'N/A',
      'answers': answers?.toString() ?? 'N/A',
    });
  }
}
