import 'dart:async';
import 'dart:convert';

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
import 'package:pictionary/repositories/webrtc_conn_manager.dart';
import 'package:pictionary/screens/game/game_similarity_notif.dart';
import 'package:pictionary/utils/audio_player.dart';
import 'game.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  final _socket = AppSocket();
  final GameRepository _gameRepository;
  GameMsgHandler _gameMsgListener;

  GameBloc(this._gameRepository) {
    _gameMsgListener = GameMsgHandler(this);
    init();
  }

  void init() async{
    _gameRepository.onExternalRoomIDReceived((roomID) {
      final currentState = state;
      if (!(currentState is GamePlaying)) {
        add(GameJoinRequested(roomID));
      } else {
        BotToast.showText(
            text: "Please exit current game and retry.",
            duration: Duration(seconds: 3));
      }
    });
  }

  @override
  GameNotPlaying get initialState => GameNotPlaying();

  User get user => _gameRepository.user;

  bool get isMicGranted => _gameRepository.micPermissionsGranted;

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
          'payload': {'gameRoomID': currentState.gameRoomID, 'userID': user.uid}
        }));
      }
      yield GameNotPlaying();
    }
    if (event is GameCreateRequested) {
      await _gameRepository.tryMicPermission();
      yield GameCreating();
      try {
        //await Future.delayed(Duration(seconds: 3));
        final newRoom =
            await _gameRepository.createPrivateRoom(event.audioEnabled);
        yield GamePlaying(
            gameDetails: GameDetails(players: [
              Player(
                  uid: user.uid,
                  nick: user.nick,
                  totalScore: 0,
                  currentScore: 0,
                  imgURL: user.avatar)
            ]),
            gameRoomID: newRoom['gameRoomID'],
            gameRoomNick: newRoom['roomUID'],
            audioEnabled: event.audioEnabled);
      } catch (error) {
        yield GameCreateFailed(error.toString());
        yield GameNotPlaying();
      }
    }
    if (event is GameJoinRequested) {
      try {
        await _gameRepository.tryMicPermission();
      } catch (e) {
        alog.e(e);
      }
      yield GameJoining();
      //await Future.delayed(Duration(seconds: 3));
      try {
        final joinedRoom = await _gameRepository.join(event.roomID);
        final gameDetails = GameDetails.fromJSON(joinedRoom);
        yield GamePlaying(
            gameDetails: gameDetails,
            gameRoomID: joinedRoom['gameRoomID'],
            audioEnabled: joinedRoom['audio'],
            gameRoomNick: event.roomID);
      } catch (error) {
        yield GameCreateFailed(error.toString());
        yield GameNotPlaying();
      }
    }
    if (event is GameJoinPubRequested) {
      yield GameJoiningPub();
      //await Future.delayed(Duration(seconds: 3));
      try {
        final joinedRoom = await _gameRepository.joinPub();
        final gameDetails = GameDetails.fromJSON(joinedRoom);
        yield GamePlaying(
            gameDetails: gameDetails,
            gameRoomID: joinedRoom['gameRoomID'],
            audioEnabled: joinedRoom['audio'],
            isPublic: true);
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
        GameSounds().playUserJoined();
      }
    }

    if (event is GameUserLeft) {
      final currentState = state;
      if (currentState is GamePlaying &&
          currentState.gameRoomID == event.gameRoomID) {
        WebRTCConnectionManager().disconnectPeer(event.playerUID);
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
        GameSounds().playUserLeft();
      }
    }
    if (event is GameHintReceived) {
      final currentState = state;
      if (currentState is GamePlaying) {
        //Receive hint only if the current artist is not me.
        if (currentState.gameDetails.currentArtist.uid != user.uid)
          yield currentState.copyWith(hint: event.hint);
      }
    }

    if (event is GameAnswerReceived) {
      final currentState = state;
      if (currentState is GamePlaying) {
        final updatedAnswers =
            List<GameAnswer>.from(currentState.answers ?? []);
        if (updatedAnswers.length >= _MAX_ANSWERS) updatedAnswers.removeLast();
        updatedAnswers.insert(0, event.gameAnswer);
        yield currentState.copyWith(answers: updatedAnswers);
        if (event.gameAnswer.correctAnswer) GameSounds().playRightGuess();
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
            duration: Duration(milliseconds: 3000));
      }
    }

    if (event is GameChoosing) {
      final currentState = state;
      if (currentState is GamePlaying) {
        yield currentState.copyWith(
            gameDetails: currentState.gameDetails.copyWithGD(event.gameDetails),
            lastWord:
                (currentState.gameDetails.state == GameStateConstants.ENDED
                    ? ''
                    : null),
            //If last state was game ended, or ignore (null will keep the previous value)
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
        yield currentState.copyWith(
            drawScores: event.playerScores, lastWord: event.lastWord);
        GameSounds().playRoundComplete();
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
        updatedPlayers
            .sort((p1, p2) => p1.currentScore < p2.currentScore ? 1 : -1);
        yield currentState.copyWith(
            drawScores: {},
            lastWinner: updatedPlayers[0],
            gameDetails: currentState.gameDetails.copyWith(
                players: updatedPlayers,
                timeout: event.timeout,
                round: 0,
                state: GameStateConstants.ENDED));

        if (updatedPlayers.length > 1) {
          // Still in game
          GameSounds().playGameFinish();
        }
        //If game is public, and game ended with only 1 player, move to GameNotPlaying.
        if (updatedPlayers.length <= 1 && currentState.isPublic) {
          add(GameExited());
        }
      }
    }

    if (event is ChoseWord) {
      final currentState = state;
      if (currentState is GamePlaying) {
        _gameMsgListener
            .submitChosenWord(currentState.wordsToChoose.indexOf(event.word));
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
      yield GamePlaying(
          gameDetails: GameDetails(
              state: GameStateConstants.DRAWING,
              players: [
                Player(
                    uid: user.uid,
                    nick: user.nick,
                    totalScore: 0,
                    currentScore: 0,
                    imgURL: user.avatar),
                Player(
                    uid: user.uid,
                    nick: user.nick,
                    totalScore: 0,
                    currentScore: 0,
                    imgURL: user.avatar),
                Player(
                    uid: user.uid,
                    nick: user.nick,
                    totalScore: 0,
                    currentScore: 0,
                    imgURL: user.avatar)
              ],
              round: 1,
              startTimeMs: DateTime.now().millisecondsSinceEpoch,
              targetTimeMs: DateTime.now().millisecondsSinceEpoch + 600000,
              currentArtist: Player(
                  uid: user.uid,
                  nick: user.nick,
                  totalScore: 0,
                  currentScore: 0,
                  imgURL: user.avatar)),
          wordsToChoose: ["dummy word", "one more", "more than one"],
          lastWord: "Test last word",
          hint: "dsadasd",
          answers: [
            GameAnswer(
                fromPlayer: Player(
                    uid: user.uid,
                    nick: user.nick,
                    totalScore: 0,
                    currentScore: 0,
                    imgURL: user.avatar),
                answer: "sdasd",
                correctAnswer: false),
            GameAnswer(
                fromPlayer: Player(
                    uid: user.uid,
                    nick: user.nick,
                    totalScore: 0,
                    currentScore: 0,
                    imgURL: user.avatar),
                answer: "Guessed it!",
                correctAnswer: true)
          ]);
    }
  }

  @override
  Future<void> close() {
    // TODO: implement close
    _gameRepository.dispose();
    _gameMsgListener.dispose();
    return super.close();
  }
}
