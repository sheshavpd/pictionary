import 'dart:async';
import 'dart:convert';

import 'package:pictionary/blocs/game/game.dart';
import 'package:pictionary/blocs/game/game_sv_events.dart';
import 'package:pictionary/models/Player.dart';
import 'package:pictionary/models/game_answer.dart';
import 'package:pictionary/models/game_details.dart';
import 'package:pictionary/repositories/AppSocket.dart';

class GameMsgHandler {
  StreamSubscription<String> _subscription;
  final Map<dynamic, Function> _msgHandlers = {};
  final GameBloc gameBloc;
  final _socket = AppSocket();

  GameMsgHandler(this.gameBloc) {
    _subscription = _socket.message.listen(onMessageReceived);
    _initHandlers();
  }

  void submitGuess(String guessText) {
    final currentState = gameBloc.state;
    if (currentState is GamePlaying)
      _socket.sendMessage(json.encode({
        'type' : GameEventConstants.GUESS_SUBMIT,
        'payload': {
          'stateID': currentState.gameDetails.stateID,
          'gameUID': currentState.gameDetails.gameUID,
          'word': guessText
        }
      }));
  }

  void submitChosenWord(int wordIndex) {
    final currentState = gameBloc.state;
    if (currentState is GamePlaying)
      _socket.sendMessage(json.encode({
        'type' : GameEventConstants.WORD_CHOSEN,
        'payload': {
          'stateID': currentState.gameDetails.stateID,
          'gameUID': currentState.gameDetails.gameUID,
          'wordIndex': wordIndex
        }
      }));
  }

  void _initHandlers() {
    _msgHandlers[GameEventConstants.USER_JOINED] = this.userJoinMessage;
    _msgHandlers[GameEventConstants.USER_LEFT] = this.userLeftMessage;
    _msgHandlers[GameEventConstants.HINT] = this.receivedHint;
    _msgHandlers[GameEventConstants.GUESS_SUCCESS] =
        (msg) => receivedAnswer(msg, true, 'Guessed it.');
    _msgHandlers[GameEventConstants.GUESS_FAIL] =
        (msg) => receivedAnswer(msg, false, msg['word']);
    _msgHandlers[GameEventConstants.GUESS_SIMILAR] = receivedSimilar;
    _msgHandlers[GameEventConstants.DRAWING_STARTED] = drawingStarted;
    _msgHandlers[GameEventConstants.CHOOSING_STARTED] = choosingStarted;
    _msgHandlers[GameEventConstants.DRAWING_COMPLETE] = drawingComplete;
    _msgHandlers[GameEventConstants.GAME_ENDED] = drawingEnded;
  }

  void onMessageReceived(String message) {
    Map msg;
    try {
      msg = json.decode(message);
    } catch (_) {
      return;
    }
    if (_msgHandlers[msg['type']] != null) {
      _msgHandlers[msg['type']](msg);
    } else {
      print("Socket message: ${msg['type']} not handled");
    }
  }

  void userJoinMessage(Map msg) {
    gameBloc.add(GameUserJoined(
        Player(
            nick: msg['name'],
            uid: msg['uid'],
            imgURL: msg['avatar'],
            currentScore: 0,
            totalScore: msg['totalScore']),
        msg['gameRoomID']));
  }

  void userLeftMessage(Map msg) {
    gameBloc.add(GameUserLeft(msg['uid'], msg['gameRoomID']));
  }

  void receivedHint(Map msg) {
    gameBloc.add(GameHintReceived(msg['hint']));
  }

  void receivedAnswer(Map msg, bool correctAnswer, String word) {
    final currentState = gameBloc.state;
    if (currentState is GamePlaying) {
      final answerer = currentState.gameDetails.players
          .firstWhere((player) => player.uid == msg['uid'], orElse: () => null);
      gameBloc.add(GameAnswerReceived(GameAnswer(
          correctAnswer: correctAnswer, answer: word, fromPlayer: answerer)));
    }
  }

  void receivedSimilar(Map msg) {
    gameBloc.add(
        GameAnswerSimilar(similarity: msg['similarity'], answer: msg['word']));
  }

  void choosingStarted(Map msg) {
    final currentState = gameBloc.state;
    if (currentState is GamePlaying) {
      final gameDetails = GameDetails.fromJSON(msg);
      gameDetails.players.sort((p1, p2) => p1.currentScore < p2.currentScore ? 1: -1);
      gameBloc.add(
          GameChoosing(gameDetails: gameDetails, words: msg['words'] ==null ? [] : List<String>.from(msg['words'])));
    }
  }

  void drawingStarted(Map msg) {
    GameDetails gameDetails = GameDetails.fromJSON(msg);
    gameBloc
        .add(GameDrawingStarted(gameDetails: gameDetails, hint: msg['hint']));
  }

  void drawingComplete(Map msg) {
    gameBloc
        .add(GameDrawingComplete(playerScores: msg['drawScores'], lastWord: msg['word']));
  }

  void drawingEnded(Map msg) {
    gameBloc
        .add(GameEnded(playerScores: msg['scores'], timeout: msg['timeout']));
  }

  void dispose() {
    _subscription.cancel();
  }
}
