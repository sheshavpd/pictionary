import 'package:bot_toast/bot_toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pictionary/blocs/canvas/canvas.dart';
import 'package:pictionary/blocs/game/game.dart';
import 'package:pictionary/blocs/game/game_sv_events.dart';
import 'package:pictionary/repositories/mediastream_manager.dart';
import 'package:pictionary/repositories/webrtc_conn_manager.dart';
import 'package:pictionary/screens/game/game_draw_screen.dart';
import 'package:pictionary/screens/game/game_messages.dart';
import 'package:pictionary/screens/game/game_stats.dart';
import 'package:pictionary/screens/game/game_timeout.dart';
import 'package:pictionary/screens/game/scribble_painter_client.dart';
import 'package:pictionary/utils/helpers.dart';
import 'package:pictionary/widgets/game_button.dart';
import 'package:pictionary/widgets/placeholder_image.dart';

import 'answer_hint.dart';
import 'game_players.dart';

const _HEADER_HEIGHT = 40.0;

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  WebRTCConnectionManager _webRTCConnectionManager;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    GameBloc gameBloc = BlocProvider.of<GameBloc>(context);
    if(!gameBloc.isMicGranted || !(gameBloc.state is GamePlaying))
      return;
    _webRTCConnectionManager = WebRTCConnectionManager();
    final players = (gameBloc.state as GamePlaying).gameDetails.players;
    //If there are only 2 players, let the second player initiate the peer connection.
    if(players.length <= 2 && players[0].uid != gameBloc.user.uid)
      return;
    players?.forEach((p) {
      if(p.uid != gameBloc.user.uid)
        _webRTCConnectionManager.connectPeer(p.uid);
    });
  }
  @override
  Widget build(BuildContext context) {
    if (!(BlocProvider.of<GameBloc>(context).state is GamePlaying)) {
      //BlocProvider.of<GameBloc>(context).add(GameTest());
      return SizedBox.shrink();
    }
    return BlocProvider<CanvasBloc>(
      create: (context) => CanvasBloc(BlocProvider.of<GameBloc>(context)),
      child: _GameRoot(),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _webRTCConnectionManager.dispose();
  }
}

class _GameRoot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameBloc, GameState>(
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
    final roomNick =
        (BlocProvider.of<GameBloc>(context).state as GamePlaying).gameRoomNick;
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
          FancyButton(
            color: Colors.purple,
            size: 20,
            child: Text(
              "Invite",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            onPressed: () {},
          ),
          Flexible(
            child: Container(
              margin: EdgeInsets.only(left: 5, right: 5),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 1),
                  borderRadius: BorderRadius.circular(5)),
              child: FlatButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: roomNick));
                  BotToast.showText(text: "Copied!");
                },
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: EdgeInsets.all(0),
                child: Text(
                  "$roomNick",
                  style: TextStyle(color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
          Row(
            children: <Widget>[
              FancyButton(
                color: Colors.purple,
                size: 20,
                child: Icon(
                  FontAwesomeIcons.microphone,
                  color: Colors.white,
                  size: 17.0,
                ),
                onPressed: () {},
              ),
              SizedBox(width: 10),
              FancyButton(
                color: Colors.purple,
                size: 20,
                child: Icon(
                  FontAwesomeIcons.volumeUp,
                  color: Colors.white,
                  size: 17.0,
                ),
                onPressed: () {},
              ),
              SizedBox(width: 10),
              FancyButton(
                color: Colors.purple,
                size: 20,
                child: Icon(
                  FontAwesomeIcons.signOutAlt,
                  color: Colors.white,
                  size: 17.0,
                ),
                onPressed: () {
                  BlocProvider.of<GameBloc>(context).add(GameExited());
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
          )
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
