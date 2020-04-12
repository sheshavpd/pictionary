import 'package:bot_toast/bot_toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pictionary/blocs/audiortc/audio.dart';
import 'package:pictionary/blocs/canvas/canvas.dart';
import 'package:pictionary/blocs/connection/connection.dart';
import 'package:pictionary/blocs/game/game.dart';
import 'package:pictionary/blocs/game/game_sv_events.dart';
import 'package:pictionary/screens/game/game_draw_screen.dart';
import 'package:pictionary/screens/game/game_messages.dart';
import 'package:pictionary/screens/game/game_stats.dart';
import 'package:pictionary/screens/game/game_timeout.dart';
import 'package:pictionary/screens/game/scribble_painter_client.dart';
import 'package:pictionary/utils/helpers.dart';
import 'package:pictionary/widgets/game_button.dart';
import 'package:pictionary/widgets/placeholder_image.dart';

import 'answer_hint.dart';
import 'exit_confirmation.dart';
import 'game_players.dart';

const _HEADER_HEIGHT = 40.0;

class GameScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final GameBloc _gameBloc = BlocProvider.of<GameBloc>(context);
    if (!(_gameBloc.state is GamePlaying)) {
      //BlocProvider.of<GameBloc>(context).add(GameTest());
      return SizedBox.shrink();
    }
    return MultiBlocProvider(
      providers: [
        BlocProvider<CanvasBloc>(create: (context) => CanvasBloc(_gameBloc)),
        BlocProvider<AudioBloc>(
            lazy: false,
            create: (context) {
              return AudioBloc(_gameBloc)
                ..add(AudioSetInGameAudioEnabled(_gameBloc.isMicGranted &&
                    (_gameBloc.state as GamePlaying).audioEnabled));
            })
      ],
      child: _GameRoot(),
    );
  }
}

class _GameRoot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocListener<ConnectionBloc, AppConnectionState>(
      listener: (context, state) {
        if (!(state is ConnectionConnected)) {
          showDialog(
            context: context,
            builder: (BuildContext DialogCtx) {
              return AlertDialog(
                title: Text(
                  "Sorry!",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                content: Text(
                    "Yout connection doesn't seem to be stable. You got disconnected from the game :("),
                actions: <Widget>[
                  // usually buttons at the bottom of the dialog
                  FancyButton(
                    size: 20,
                    color: Theme.of(context).primaryColor,
                    child: Text(
                      "I understand",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () async {
                      Navigator.of(DialogCtx).pop();
                    },
                  )
                ],
              );
            },
          );
          BlocProvider.of<GameBloc>(context).add(GameExited());
        }
      },
      child: BlocBuilder<GameBloc, GameState>(
        condition: (previous, present) {
          return (present is GamePlaying) &&
              (previous as GamePlaying).gameDetails.state !=
                  (present as GamePlaying).gameDetails.state;
        },
        builder: (context, state) {
          final cState = state as GamePlaying;
          final iAmCurrentArtist = cState.gameDetails.currentArtist != null &&
              cState.gameDetails.currentArtist.uid ==
                  BlocProvider.of<GameBloc>(context).user.uid;
          return Stack(
            children: <Widget>[
              (cState.gameDetails.state == GameStateConstants.DRAWING &&
                      iAmCurrentArtist)
                  ? GameDrawScreen()
                  : _GuessingScreen(),
              cState.gameDetails.state == GameStateConstants.CHOOSING ||
                      cState.gameDetails.state == GameStateConstants.ENDED
                  ? GameStatsDialog()
                  : SizedBox.shrink()
            ],
          );
        },
      ),
    );
  }
}

class _GuessingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          height: _HEADER_HEIGHT,
          child: _GameHeader(),
        ),
        Stack(
          alignment: Alignment.center,
          children: <Widget>[
            _GameCanvas(),
            Positioned(
              bottom: 0,
              right: 0,
              child: Opacity(
                opacity: 0.7,
                child: GameMessages(),
              ),
            ),
            Positioned(
              top: 5,
              child: Opacity(
                opacity: 0.7,
                child: AnswerHint(),
              ),
            )
          ],
        ),
        _AnswerField(),
        PlayersList(),
        _GameFooter()
      ],
    );
  }
}

class _GameFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = (BlocProvider.of<GameBloc>(context).state as GamePlaying);
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
          color:
              hslRelativeColor(color: Theme.of(context).primaryColor, l: 0.3),
          boxShadow: [
            BoxShadow(
              color: Color.fromARGB(90, 0, 0, 0),
              blurRadius: 20.0, // has the effect of softening the shadow
              spreadRadius: 2.0, // has the effect of extending the shadow
              offset: Offset(
                0.0, // horizontal, move right 10
                -5, // vertical, move down 10
              ),
            )
          ]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          state.isPublic
              ? SizedBox.shrink()
              : FancyButton(
                  color: Colors.purple,
                  size: 20,
                  child: Text(
                    "Invite",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  onPressed: () {
                    shareGameInvitation(state.gameRoomNick);
                  },
                ),
          Flexible(
            child: Container(
              margin: EdgeInsets.only(left: 5, right: 5),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 1),
                  borderRadius: BorderRadius.circular(5)),
              child: FlatButton(
                onPressed: () {
                  if(state.isPublic)
                    return;
                  Clipboard.setData(
                      ClipboardData(text: state.gameRoomNick));
                  BotToast.showText(text: "Copied!");
                },
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: EdgeInsets.all(0),
                child: Text(
                  "${state.isPublic?'Public room':state.gameRoomNick}",
                  style: TextStyle(color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
          Row(
            children: <Widget>[
              BlocBuilder<AudioBloc, AudioState>(builder: (context, state) {
                if (state.audioEnabledInGame) {
                  return FancyButton(
                    color: Colors.purple,
                    size: 20,
                    child: Icon(
                      state.speakerEnabled
                          ? FontAwesomeIcons.volumeUp
                          : FontAwesomeIcons.volumeMute,
                      color: Colors.white,
                      size: 17.0,
                    ),
                    onPressed: () {
                      BlocProvider.of<AudioBloc>(context)
                          .add(AudioSetSpeaker(!state.speakerEnabled));
                    },
                  );
                }
                return SizedBox.shrink();
              }),
              SizedBox(width: 10),
              FancyButton(
                color: Colors.purple,
                size: 20,
                child: Row(
                  children: <Widget>[
                    Text("Exit",
                        style: TextStyle(color: Colors.white, fontSize: 15)),
                    SizedBox(width: 5),
                    Icon(
                      FontAwesomeIcons.signOutAlt,
                      color: Colors.white,
                      size: 20.0,
                    )
                  ],
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext ctx) {
                      return ExitConfirmationDialog(gameContext: context);
                    },
                  );
                },
              )
            ],
          ),
        ],
      ),
    );
  }
}

class _AnswerField extends StatefulWidget {
  @override
  __AnswerFieldState createState() => __AnswerFieldState();
}

class __AnswerFieldState extends State<_AnswerField> {
  final _controller = TextEditingController();

  Widget _renderAudioControls() {
    return BlocBuilder<AudioBloc, AudioState>(builder: (context, state) {
      if (state.audioEnabledInGame) {
        return Container(
          margin: EdgeInsets.only(left: 10),
          child: FancyButton(
            color: Colors.purple,
            size: 20,
            child: Icon(
              state.audioRecording
                  ? FontAwesomeIcons.microphone
                  : FontAwesomeIcons.microphoneSlash,
              color: Colors.white,
              size: 17.0,
            ),
            onPressed: () {
              BlocProvider.of<AudioBloc>(context)
                  .add(AudioSetMicrophone(!state.audioRecording));
            },
          ),
        );
      }
      return SizedBox.shrink();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 0, right: 5),
      color: hslRelativeColor(color: Theme.of(context).primaryColor, l: 0.45),
      child: Row(
        children: <Widget>[
          Flexible(
            child: TextField(
              controller: _controller,
              maxLines: 1,
              autocorrect: false,
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.only(left: 10, right: 10),
                  border: InputBorder.none,
                  hintText: 'Type answer here'),
              style: TextStyle(
                fontSize: 17.0,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          FancyButton(
            color: Theme.of(context).primaryColorDark,
            size: 20,
            child: Icon(
              FontAwesomeIcons.paperPlane,
              color: Colors.white,
              size: 20.0,
            ),
            onPressed: () {
              if (_controller.text.trim() == "") return;
              BlocProvider.of<GameBloc>(context)
                  .add(GuessSubmitted(_controller.text.trim()));
              _controller.text = "";
            },
          ),
          _renderAudioControls()
        ],
      ),
    );
  }
}

class _GameCanvas extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: new BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color.fromARGB(30, 0, 0, 0),
            blurRadius: 20.0, // has the effect of softening the shadow
            spreadRadius: 2.0, // has the effect of extending the shadow
            offset: Offset(
              0.0, // horizontal, move right 10
              0.0, // vertical, move down 10
            ),
          ),
        ],
      ),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.width * 9 / 16,
      child: ScribbleClient(),
    );
  }
}

class _GameHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameBloc, GameState>(
      condition: (previous, present) {
        if (previous is GamePlaying && present is GamePlaying) {
          return (previous.gameDetails.currentArtist !=
                  present.gameDetails.currentArtist ||
              previous.gameDetails.targetTimeMs !=
                  present.gameDetails.targetTimeMs);
        }
        return false;
      },
      builder: (context, state) {
        final cState = state as GamePlaying;
        if (cState.gameDetails.currentArtist == null) return SizedBox.shrink();
        return Stack(
          children: <Widget>[
            Container(
              height: _HEADER_HEIGHT,
              child: GameTimeout(
                startTimeMs: cState.gameDetails.startTimeMs,
                targetTimeMs: cState.gameDetails.targetTimeMs,
                center: (String secondsRemaining) {
                  return Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        padding: EdgeInsets.only(right: 10),
                        child: Text(
                          "$secondsRemaining",
                          style: TextStyle(color: Colors.orange.shade900),
                        ),
                      ));
                },
                color: Theme.of(context).primaryColor.withAlpha(60),
              ),
            ),
            SizedBox.expand(
              child: Container(
                padding: EdgeInsets.only(left: 5, right: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(children: <Widget>[
                      CircleAvatar(
                        radius: 15,
                        child: ClipOval(
                          child: CachedNetworkImage(
                            imageUrl:
                                cState.gameDetails.currentArtist.imgURL ?? '',
                            placeholder: (context, url) => placeholderImage,
                            errorWidget: (context, url, error) =>
                                placeholderImage,
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 5),
                        constraints: BoxConstraints(
                          maxWidth: 140,
                        ),
                        child: Text(cState.gameDetails.currentArtist.nick,
                            overflow: TextOverflow.ellipsis,
                            style:
                                TextStyle(color: Colors.deepPurple.shade900)),
                      )
                    ]),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
