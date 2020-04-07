import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:pictionary/blocs/game/game_sv_events.dart';
import 'package:pictionary/common/app_logger.dart';
import 'package:pictionary/models/Player.dart';
import 'package:pictionary/models/game_answer.dart';
import 'package:pictionary/models/game_details.dart';
import 'package:pictionary/models/models.dart';
import 'package:pictionary/repositories/AppSocket.dart';
import 'package:pictionary/repositories/data_providers/game_msg_listener.dart';
import 'package:pictionary/repositories/game_repository.dart';

import 'package:bloc/bloc.dart';
import 'package:pictionary/screens/game/game_similarity_notif.dart';
import 'game.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  final _socket = AppSocket();
  final GameRepository _gameRepository;
  GameMsgHandler _gameMsgListener;

  GameBloc(this._gameRepository) {
    _gameMsgListener = GameMsgHandler(this);
  }

  @override
  GameNotPlaying get initialState => GameNotPlaying();
  User get _user => _gameRepository.user;

  static const _MAX_ANSWERS = 15;

  @override
  Stream<GameState> mapEventToState(
    GameEvent event,
  ) async* {
    if (event is GameExited) {
      final currentState = state;
      if (currentState is GamePlaying) {
        _socket.sendMessage(json.encode({
          'type': GameEventConstants.USER_LEFT,
          'payload': {
            'gameRoomID': currentState.gameRoomID,
            'userID': _user.uid
          }
        }));
      }
      yield GameNotPlaying();
    }
    if (event is GameCreateRequested) {
      yield GameCreating();
      try {
        //await Future.delayed(Duration(seconds: 3));
        final newRoom = await _gameRepository.createPrivateRoom();
        yield GamePlaying(
            gameDetails: GameDetails(players: [
              Player(
                  uid: _user.uid,
                  nick: _user.nick,
                  totalScore: 0,
                  currentScore: 0,
                  imgURL: _user.avatar)
            ]),
            gameRoomID: newRoom['gameRoomID'],
            gameRoomNick: newRoom['roomUID']);
      } catch (error) {
        yield GameCreateFailed(error.toString());
        yield GameNotPlaying();
      }
    }
    if (event is GameJoinRequested) {
      yield GameJoining();
      //await Future.delayed(Duration(seconds: 3));
      try {
        final joinedRoom = await _gameRepository.join(event.roomID);
        final gameDetails = GameDetails.fromJSON(joinedRoom);
        yield GamePlaying(
            gameDetails: gameDetails,
            gameRoomID: joinedRoom['gameRoomID'],
            gameRoomNick: event.roomID);
      } catch (error) {
        yield GameCreateFailed(error.toString());
        yield GameNotPlaying();
      }
    }
    if (event is GameUserJoined) {
      final currentState = state;
      final newPlayer = event.newPlayer;
      if (currentState is GamePlaying &&
          currentState.gameRoomID == event.gameRoomID) {
        //Remove the player if exists.
        currentState.gameDetails.players
            .removeWhere((player) => player.uid == newPlayer.uid);
        yield currentState.copyWith(
            gameDetails: currentState.gameDetails.copyWith(
                players: currentState.gameDetails.players + [newPlayer]));
        BotToast.showText(
            text: "${newPlayer.nick} joined", align: Alignment(0, -0.8));
      }
    }

    if (event is GameUserLeft) {
      final currentState = state;
      if (currentState is GamePlaying &&
          currentState.gameRoomID == event.gameRoomID) {
        List<Player> currentPlayers =
            List<Player>.from(currentState.gameDetails.players);
        Player removedPlayer;
        currentPlayers.removeWhere((player) {
          if (player.uid == event.playerUID) {
            removedPlayer = player;
            return true;
          }
          return false;
        });
        yield currentState.copyWith(
            gameDetails:
                currentState.gameDetails.copyWith(players: currentPlayers));
        BotToast.showText(
            text: "${removedPlayer.nick} left", align: Alignment(0, -0.8));
      }
    }
    if (event is GameHintReceived) {
      final currentState = state;
      if (currentState is GamePlaying) {
        //Receive hint only if the current artist is not me.
        if(currentState.gameDetails.currentArtist.uid != _user.uid)
          yield currentState.copyWith(hint: event.hint);
      }
    }

    if (event is GameAnswerReceived) {
      final currentState = state;
      if (currentState is GamePlaying) {
        final updatedAnswers = List<GameAnswer>.from(currentState.answers ?? []);
        if (updatedAnswers.length >= _MAX_ANSWERS)
          updatedAnswers.removeLast();
        updatedAnswers.insert(0, event.gameAnswer);
        yield currentState.copyWith(answers: updatedAnswers);
      }
    }

    if (event is GameAnswerSimilar) {
      final currentState = state;
      if (currentState is GamePlaying) {
        BotToast.showCustomNotification(
            align: Alignment(0, -1),
            toastBuilder: (cancelFunc) {
              return GameSimilarityNotif(
                  similarityText:
                      "${event.answer} is ${event.similarity}% similar");
            },
            backButtonBehavior: BackButtonBehavior.ignore,
            duration: Duration(milliseconds: 1000));
      }
    }

    if (event is GameChoosing) {
      final currentState = state;
      if (currentState is GamePlaying) {
        yield currentState.copyWith(
            gameDetails: currentState.gameDetails.copyWithGD(event.gameDetails),
            wordsToChoose: event.words);
      }
    }

    if (event is GameDrawingStarted) {
      final currentState = state;
      if (currentState is GamePlaying) {
        yield currentState.copyWith(
            gameDetails: currentState.gameDetails.copyWithGD(event.gameDetails),
            hint: event.hint);
      }
    }

    if (event is GameDrawingComplete) {
      final currentState = state;
      if (currentState is GamePlaying) {
        List<Player> updatedPlayers = currentState.gameDetails.players.map((p) {
          if (event.playerScores.containsKey(p.uid)) {
            return p.copyWith(drawScore: event.playerScores[p.uid]);
          } else
            return p;
        }).toList();
        yield currentState.copyWith(
            gameDetails:
                currentState.gameDetails.copyWith(players: updatedPlayers ),
            lastWord: event.lastWord);
      }
    }

    if (event is GameEnded) {
      final currentState = state;
      if (currentState is GamePlaying) {
        List<Player> updatedPlayers = currentState.gameDetails.players.map((p) {
          if (event.playerScores.containsKey(p.uid)) {
            return p.copyWith(currentScore: event.playerScores[p.uid]);
          } else
            return p;
        }).toList();
        updatedPlayers.sort((p1, p2) => p1.currentScore < p2.currentScore?1:-1);
        yield currentState.copyWith(
            gameDetails:
            currentState.gameDetails.copyWith(players: updatedPlayers, timeout: event.timeout, round: 0, state: GameStateConstants.ENDED));
      }
    }

    if (event is ChoseWord) {
      final currentState = state;
      if (currentState is GamePlaying) {
        _gameMsgListener.submitChosenWord(currentState.wordsToChoose.indexOf(event.word));
        yield currentState.copyWith(wordsToChoose: []);
      }
    }

    if (event is GuessSubmitted) {
      final currentState = state;
      if (currentState is GamePlaying) {
        _gameMsgListener.submitGuess(event.word);
      }
    }

    if (event is GameTest) {
      yield GamePlaying(gameDetails: GameDetails(
        state: GameStateConstants.DRAWING,
        players: [
          Player(
              uid: _user.uid,
              nick: _user.nick,
              totalScore: 0,
              currentScore: 0,
              imgURL: _user.avatar),
          Player(
              uid: _user.uid,
              nick: _user.nick,
              totalScore: 0,
              currentScore: 0,
              imgURL: _user.avatar),

          Player(
              uid: _user.uid,
              nick: _user.nick,
              totalScore: 0,
              currentScore: 0,
              imgURL: _user.avatar)],
        round: 1,
        startTimeMs: DateTime.now().millisecondsSinceEpoch,
        targetTimeMs: DateTime.now().millisecondsSinceEpoch + 60000,
        currentArtist: Player(
            uid: _user.uid,
            nick: _user.nick,
            totalScore: 0,
            currentScore: 0,
            imgURL: _user.avatar)
      ),
        wordsToChoose: ["dummy word", "one more", "more than one"],
        lastWord: "Test last word",
        hint: "dsadasd",
        answers: [
          GameAnswer(fromPlayer: Player(
              uid: _user.uid,
              nick: _user.nick,
              totalScore: 0,
              currentScore: 0,
              imgURL: _user.avatar), answer: "sdasd", correctAnswer: false),
          GameAnswer(fromPlayer: Player(
              uid: _user.uid,
              nick: _user.nick,
              totalScore: 0,
              currentScore: 0,
              imgURL: _user.avatar), answer: "Guessed it!", correctAnswer: true)
        ]
      );
    }
  }

  @override
  Future<void> close() {
    // TODO: implement close
    _gameMsgListener.dispose();
    return super.close();
  }
}
