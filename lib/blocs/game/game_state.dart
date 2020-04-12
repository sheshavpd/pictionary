import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:pictionary/common/pretty_print.dart';
import 'package:pictionary/models/Player.dart';
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

class GameJoiningPub extends GameState {
  @override
  String toString() => 'GameJoiningPub';
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
  final Map drawScores;
  final String gameRoomID;
  final String gameRoomNick;
  final bool isPublic;
  final bool audioEnabled;
  final String hint;
  final String lastWord;
  final Player lastWinner;
  final GameDetails gameDetails;

  GamePlaying(
      {this.gameDetails,
      this.wordsToChoose,
      this.gameRoomID,
      this.gameRoomNick,
      this.isPublic = false,
      this.audioEnabled,
      this.hint,
      this.lastWord,
      this.lastWinner,
      this.drawScores,
      this.answers});

  GamePlaying copyWith(
      {GameDetails gameDetails,
      List<GameAnswer> answers,
      List<String> wordsToChoose,
      Map drawScores,
      String gameRoomID,
      String gameRoomNick,
      bool isPublic,
      bool audioEnabled,
      Player lastWinner,
      String hint,
      String lastWord}) {
    return GamePlaying(
        gameDetails: gameDetails ?? this.gameDetails,
        answers: answers ?? this.answers,
        wordsToChoose: wordsToChoose ?? this.wordsToChoose,
        gameRoomID: gameRoomID ?? this.gameRoomID,
        gameRoomNick: gameRoomNick ?? this.gameRoomNick,
        isPublic: isPublic ?? this.isPublic,
        audioEnabled: audioEnabled ?? this.audioEnabled,
        hint: hint ?? this.hint,
        lastWinner: lastWinner ?? this.lastWinner,
        drawScores: drawScores ?? this.drawScores,
        lastWord: lastWord ?? this.lastWord);
  }

  @override
  List<Object> get props => [
        this.gameRoomID,
        gameRoomNick,
        isPublic,
        audioEnabled,
        hint,
        lastWord,
        wordsToChoose,
        lastWinner,
        gameDetails,
        drawScores,
        answers,
      ];

  @override
  String toString() {
    return "GamePlaying";
  }

  String toVerboseString() {
    return prettyPrint({
      'gameRoomID': this.gameRoomID,
      'gameRoomNick': gameRoomNick,
      'hint': hint,
      'lastWord': lastWord,
      'lastWinner': lastWinner?.toString() ?? 'N/A',
      'wordsToChoose': wordsToChoose?.toString() ?? 'N/A',
      'gameDetails': gameDetails?.toString() ?? 'N/A',
      'drawScores': drawScores?.toString() ?? 'N/A',
      'answers': answers?.toString() ?? 'N/A',
    });
  }
}
