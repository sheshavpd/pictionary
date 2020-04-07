import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pictionary/blocs/game/game.dart';
import 'package:pictionary/blocs/game/game_sv_events.dart';
import 'package:pictionary/models/Player.dart';
import 'package:pictionary/utils/helpers.dart';
import 'package:pictionary/widgets/game_button.dart';
import 'package:pictionary/widgets/placeholder_image.dart';

class PlayersList extends StatelessWidget {
  _getListItem(List<Player> players, context, index) {
    final oddIndex = index % 2 == 0;
    final gradient = [
      Theme.of(context).primaryColor,
      Theme.of(context).primaryColorDark
    ];
    final reverseGradient = [
      Theme.of(context).primaryColorDark,
      Theme.of(context).primaryColor
    ];
    final color = players[index].currentScore < 0 ? Colors.red : Colors.amber;
    return Card(
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).primaryColor.withAlpha(150),
              blurRadius: 3.0, // has the effect of softening the shadow
              spreadRadius: 1.0, // has the effect of extending the shadow
              offset: Offset(
                0.0, // horizontal, move right 10
                0.0, // vertical, move down 10
              ),
            )
          ],
          borderRadius: BorderRadius.circular(5),
          gradient: LinearGradient(
            colors: oddIndex ? gradient : reverseGradient, // whitish to gray
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Flexible(
              child: Row(children: <Widget>[
                CircleAvatar(
                  radius: 15,
                  child: ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: players[index].imgURL ?? '',
                      placeholder: (context, url) => placeholderImage,
                      errorWidget: (context, url, error) => placeholderImage,
                    ),
                  ),
                ),
                Flexible(
                  child: Container(
                    margin: EdgeInsets.only(left: 5),
                    child: Text(players[index].nick,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              ]),
            ),
            Row(
              children: <Widget>[
                Stack(
                  children: <Widget>[
                    FancyButton(
                      color: color,
                      size: 15,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: <Widget>[
                          Icon(
                            FontAwesomeIcons.cookieBite,
                            color: hslRelativeColor(color: color, l: -0.2),
                            size: 15.0,
                          ),
                          Text(
                            " ${players[index].currentScore}",
                            style: TextStyle(
                                fontSize: 17,
                                color: hslRelativeColor(color: color, l: -0.2)),
                          )
                        ],
                      ),
                    ),
                    _userCurrentRoundScore(players[index], context)
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameBloc = BlocProvider.of<GameBloc>(context);
    final currentState = gameBloc.state;
    List<Player> players =
        (currentState is GamePlaying) ? currentState.gameDetails.players : [];
    return Flexible(
      child: ListView.builder(
        padding: EdgeInsets.only(top: 5),
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return _getListItem(players, context, index);
        },
        itemCount: players.length,
      ),
    );
  }

  Widget _userCurrentRoundScore(Player player, context) {
    GamePlaying state = BlocProvider.of<GameBloc>(context).state as GamePlaying;
    if (state.gameDetails.state == GameStateConstants.CHOOSING && player.drawScore != null && player.drawScore != 0)
      return Positioned(
        bottom: 0,
        right: 0,
        child: Container(
          transform: Matrix4.translationValues(5, 9, 0),
          child: CircleAvatar(
            backgroundColor: Colors.limeAccent,
            radius: 10,
            child: Text("${player.drawScore}",
                style: TextStyle(
                    fontSize: 13,
                    color:
                        hslRelativeColor(color: Colors.limeAccent, l: -0.3))),
          ),
        ),
      );
    else
      return SizedBox.shrink();
  }
}
