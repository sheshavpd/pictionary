import 'package:bot_toast/bot_toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';
import 'package:pictionary/blocs/game/game.dart';
import 'package:pictionary/blocs/game/game_bloc.dart';
import 'package:pictionary/blocs/game/game_event.dart';
import 'package:pictionary/blocs/game/game_sv_events.dart';
import 'package:pictionary/repositories/game_repository.dart';
import 'package:pictionary/screens/game/choosable_words.dart';
import 'package:pictionary/screens/game/game_players.dart';
import 'package:pictionary/widgets/game_button.dart';
import 'package:pictionary/widgets/placeholder_image.dart';

import 'game_timeout.dart';

class GameStatsDialog extends StatelessWidget {
  Widget _artistImage(GamePlaying state) {
    return Positioned(
        left: _Consts.padding,
        right: _Consts.padding,
        child: AnimatedSwitcher(
          duration: Duration(milliseconds: 400),
          child: state.gameDetails.state == GameStateConstants.CHOOSING
              ? CircleAvatar(
                  backgroundColor: Colors.deepPurple,
                  radius: _Consts.avatarRadius,
                  child: ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: state.gameDetails.currentArtist.imgURL ?? '',
                      placeholder: (context, url) => placeholderImage,
                      errorWidget: (context, url, error) => placeholderImage,
                    ),
                  ))
              : SizedBox.shrink(),
        ));
  }

  Widget _gameEnded(GamePlaying state) {
    return (state.gameDetails.state == GameStateConstants.ENDED)
        ? Container(
            margin: EdgeInsets.only(bottom: 5),
            child: Text(
              "GAME ENDED",
              style: TextStyle(fontSize: 17, color: Colors.purple),
            ),
          )
        : SizedBox.shrink();
  }

  Widget _roundNum(GamePlaying state) {
    return (state.gameDetails.round != null && state.gameDetails.round != 0)
        ? Container(
            margin: EdgeInsets.only(bottom: 5),
            child: Text(
              "ROUND ${state.gameDetails.round}",
              style: TextStyle(fontSize: 17, color: Colors.purple),
            ),
          )
        : SizedBox.shrink();
  }

  Widget _lastWordWas(GamePlaying state, BuildContext context) {
    return (state.lastWord != null && state.lastWord != '')
        ? Container(
            margin: EdgeInsets.only(bottom: 5),
            child: Wrap(
              spacing: 5,
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: <Widget>[
                Text("The word was"),
                Container(
                  padding: EdgeInsets.all(2),
                  margin: EdgeInsets.only(left: 5, right: 5),
                  decoration: BoxDecoration(
                      border: Border.all(
                          color: Theme.of(context).primaryColor, width: 1),
                      borderRadius: BorderRadius.circular(5)),
                  child: Text(
                    "${state.lastWord}",
                    style: TextStyle(color: Theme.of(context).primaryColor),
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              ],
            ),
          )
        : SizedBox.shrink();
  }

  Widget _artistChoosing(GamePlaying state) {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 400),
      child: state.gameDetails.state == GameStateConstants.CHOOSING
          ? Text("${state.gameDetails.currentArtist.nick} is the artist",
              softWrap: true,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17.0,
                fontWeight: FontWeight.w700,
              ))
          : SizedBox.shrink(),
    );
  }

  Widget _showTimeout(GamePlaying state) {
    return state.gameDetails.state == GameStateConstants.CHOOSING ||
            state.gameDetails.state == GameStateConstants.ENDED
        ? Container(
            height: 10,
            child: GameTimeout(
                startTimeMs: state.gameDetails.startTimeMs,
                targetTimeMs: state.gameDetails.targetTimeMs),
          )
        : SizedBox.shrink();
  }

  Widget _artistChoosableWords(GamePlaying state, BuildContext context) {
    final currentArtistUID =
        RepositoryProvider.of<GameRepository>(context).user.uid;
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 400),
      child: state.gameDetails.state == GameStateConstants.CHOOSING &&
              state.gameDetails.currentArtist.uid == currentArtistUID
          ? ChoosableWords(
              words: state.wordsToChoose ?? [],
              onClick: (word) {
                BlocProvider.of<GameBloc>(context).add(ChoseWord(word));
              },
            )
          : SizedBox.shrink(),
    );
  }

  _dialogContent(BuildContext context) {
    return BlocBuilder<GameBloc, GameState>(
      builder: (context, st) {
        if (!(st is GamePlaying)) {
          return SizedBox.shrink();
        }
        final GamePlaying state = st as GamePlaying;
        return Stack(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top: _Consts.avatarRadius),
              decoration: new BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(_Consts.padding),
                image: DecorationImage(
                    image: AssetImage("assets/images/doodle.jpg"),
                    fit: BoxFit.cover,
                    colorFilter:
                        ColorFilter.mode(Colors.white, BlendMode.dstATop)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10.0,
                    offset: const Offset(0.0, 10.0),
                  ),
                ],
              ),
              child: Container(
                decoration: new BoxDecoration(
                    color: Color.fromARGB(220, 255, 255, 255),
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(_Consts.padding)),
                padding: EdgeInsets.only(
                  top: _Consts.avatarRadius + _Consts.padding,
                  bottom: _Consts.padding,
                  left: _Consts.padding,
                  right: _Consts.padding,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min, // To make the card compact
                  children: <Widget>[
                    _gameEnded(state),
                    _roundNum(state),
                    _lastWordWas(state, context),
                    _artistChoosing(state),
                    _showTimeout(state),
                    _artistChoosableWords(state, context),
                    PlayersList(),
                    SizedBox(height: 16.0)
                  ],
                ),
              ),
            ),
            _artistImage(state)
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    FocusScope.of(context).unfocus(); //Dismiss any keyboard present.
    return SizedBox.expand(
        child: Container(
      color: Color.fromARGB(80, 0, 0, 0),
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(boxShadow: <BoxShadow>[
          BoxShadow(
            color: Color.fromARGB(70, 0, 0, 0),
            offset: Offset(1.0, 1.0),
            blurRadius: 10.0,
          ),
        ]),
        child: _dialogContent(context),
      ),
    ));
  }
}

class _Consts {
  _Consts._();

  static const double padding = 10.0;
  static const double avatarRadius = 40.0;
}
