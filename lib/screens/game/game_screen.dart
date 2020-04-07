import 'package:bot_toast/bot_toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pictionary/blocs/game/game.dart';
import 'package:pictionary/blocs/game/game_sv_events.dart';
import 'package:pictionary/repositories/game_repository.dart';
import 'package:pictionary/screens/game/game_messages.dart';
import 'package:pictionary/screens/game/game_stats.dart';
import 'package:pictionary/screens/game/game_timeout.dart';
import 'package:pictionary/utils/helpers.dart';
import 'package:pictionary/widgets/game_button.dart';
import 'package:pictionary/widgets/placeholder_image.dart';

import 'game_players.dart';

const _HEADER_HEIGHT = 40.0;

class GameScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (!(BlocProvider
        .of<GameBloc>(context)
        .state is GamePlaying)) {
      BlocProvider
          .of<GameBloc>(context).add(GameTest());
      return SizedBox.shrink();
    }
    return BlocBuilder<GameBloc, GameState>(
      condition: (previous, present) {
        return (present is GamePlaying) && (previous as GamePlaying).gameDetails.state !=
            (present as GamePlaying).gameDetails.state;
      },
      builder: (context, state) {
        final cState = state as GamePlaying;
        return Stack(
          children: <Widget>[
            _GuessingScreen(),
            cState.gameDetails.state == GameStateConstants.CHOOSING || cState.gameDetails.state == GameStateConstants.ENDED
                ?
            GameStatsDialog()
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
                child: _AnswerHint(),
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
    final roomNick = (BlocProvider.of<GameBloc>(context).state as GamePlaying).gameRoomNick;
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: hslRelativeColor(color: Theme
              .of(context)
              .primaryColor, l: 0.3),
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
          ]
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          FancyButton(
            color: Colors.purple,
            size: 20,
            child: Text("Invite", style: TextStyle(color: Colors.white, fontSize: 16),),
            onPressed: () {},
          ),
          Flexible(
            child: Container(
              margin: EdgeInsets.only(left: 5, right: 5),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 1),
                  borderRadius: BorderRadius.circular(5)
              ),
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


const texts = [
  "!23132",
  "sdasdsad",
  "fsasdas",
  "!23132",
  "sdasdsad",
  "fsasdas",
  "!23132",
  "sdasdsad",
  "fsasdas"
];
//const texts = ["!23132", "sdasdsad", "fsasdas", "!23132"];

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
      color: hslRelativeColor(color: Theme
          .of(context)
          .primaryColor, l: 0.45),
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
            color: Theme
                .of(context)
                .primaryColorDark,
            size: 20,
            child: Icon(
              FontAwesomeIcons.paperPlane,
              color: Colors.white,
              size: 20.0,
            ),
            onPressed: () {
              if(_controller.text.trim() == "")
                return;
              BlocProvider.of<GameBloc>(context).add(
                  GuessSubmitted(_controller.text.trim()));
              _controller.text = "";
            },
          )
        ],
      ),
    );
  }
}


class _AnswerHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = (BlocProvider
        .of<GameBloc>(context)
        .state as GamePlaying);
    if(state.gameDetails.currentArtist == null || state.hint == null)
      return SizedBox.shrink();
    final user = RepositoryProvider
        .of<GameRepository>(context)
        .user;
    final isCurrentArtist = state.gameDetails.currentArtist.uid == user.uid;
    final hint = isCurrentArtist ? state.hint : state.hint.split("").join(" ");
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.amber),
        borderRadius: BorderRadius.circular(5),
      ),
      padding: EdgeInsets.all(5),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            transform: Matrix4.translationValues(-20, 0, 0),
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5), color: Colors.amber),
            child: Icon(
              isCurrentArtist ? FontAwesomeIcons.pencilAlt : FontAwesomeIcons
                  .lightbulb,
              color: hslRelativeColor(s: -0.2, l: -0.4, color: Colors.amber),
              size: 20.0,
            ),
          ),
          Container(
            transform: Matrix4.translationValues(-10, 0, 0),
            child: Text(
              hint,
              style: TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.w700,
                color: hslRelativeColor(s: -0.2, l: -0.4, color: Colors.amber),
              ),
            ),
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
      height: MediaQuery
          .of(context)
          .size
          .width * 9 / 16,
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
                  present.gameDetails.targetTimeMs
          );
        }
        return false;
      },
      builder: (context, state) {
        final cState = state as GamePlaying;
        if(cState.gameDetails.currentArtist == null)
          return SizedBox.shrink();
        return Stack(
          children: <Widget>[
            Container(
              height: _HEADER_HEIGHT,
              child: GameTimeout(startTimeMs: cState.gameDetails.startTimeMs, targetTimeMs: cState.gameDetails.targetTimeMs,
              center: (String secondsRemaining){
                return Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: EdgeInsets.only(right: 10),
                    child: Text("$secondsRemaining",
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
                            imageUrl: cState.gameDetails.currentArtist.imgURL ?? '',
                            placeholder: (context, url) => placeholderImage,
                            errorWidget: (context, url, error) => placeholderImage,
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
                            style: TextStyle(
                                color: Colors.deepPurple.shade900)),
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
