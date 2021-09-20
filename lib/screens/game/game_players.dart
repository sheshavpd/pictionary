import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc/enums.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pictionary/blocs/audiortc/audio.dart';
import 'package:pictionary/blocs/game/game.dart';
import 'package:pictionary/blocs/game/game_sv_events.dart';
import 'package:pictionary/models/Player.dart';
import 'package:pictionary/repositories/game_repository.dart';
import 'package:pictionary/utils/helpers.dart';
import 'package:pictionary/widgets/game_button.dart';
import 'package:pictionary/widgets/placeholder_image.dart';


class PlayersList extends StatelessWidget {

  _showUserMicRestartDialog(BuildContext buildContext, String userID) {
    showDialog(context: buildContext,
    builder: (BuildContext context){
      return AlertDialog(
        title: Text(
          "Restart voice comm for this user?",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
            "This is a peer to peer audio voice communication."
                " Unfortunately, multiple things tend to be at fault in such a scenario. You can try restarting the voice comm to make it right."),
        actions: <Widget>[
          // usually buttons at the bottom of the dialog
          FancyButton(
            size: 20,
            color: Theme.of(buildContext).primaryColor,
            child: Text(
              "Cancel",
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          FancyButton(
            size: 20,
            color: Theme.of(buildContext).primaryColor,
            child: Text("Restart voice comm.", style: TextStyle(color: Colors.white)),
            onPressed: () {
              BlocProvider.of<AudioBloc>(buildContext)
                  .add(AudioRestartUserVoiceComm(userID));
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    });
  }

  _getColorForUserAudioState(String userID, AudioState state) {
    if(state.peerAudioStatus[userID] == null)
      return Colors.lightBlueAccent;
    switch(state.peerAudioStatus[userID]) {
      case RTCIceConnectionState.RTCIceConnectionStateCompleted:
      case RTCIceConnectionState.RTCIceConnectionStateConnected: return Colors.greenAccent;
      case RTCIceConnectionState.RTCIceConnectionStateFailed: return Colors.redAccent;
      default: return Colors.orange;
    }
  }

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
                Stack(
                  children: <Widget>[
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
                    BlocBuilder<AudioBloc, AudioState>(
                      builder: (context, state){
                        final isSameUser = RepositoryProvider.of<GameRepository>(context).user.uid == players[index].uid;
                        if(isSameUser || !state.audioEnabledInGame)
                          return SizedBox.shrink();
                        return Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              child: Container(
                                transform: Matrix4.translationValues(5, 5, 0),
                                child: Icon(Icons.mic,
                                    size: 20,
                                    color: _getColorForUserAudioState(players[index].uid, state)),
                              ),
                              onTap: () {
                                _showUserMicRestartDialog(context, players[index].uid);
                              },
                            )
                        );

                      },
                    ),

                  ],
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
        physics: ClampingScrollPhysics(),
        itemBuilder: (context, index) {
          return _getListItem(players, context, index);
        },
        itemCount: players.length,
      ),
    );
  }

  Widget _userCurrentRoundScore(Player player, context) {
    GamePlaying state = BlocProvider.of<GameBloc>(context).state as GamePlaying;
    if (state.gameDetails.state == GameStateConstants.CHOOSING &&
        state.drawScores != null &&
        state.drawScores[player.uid] != null &&
        state.drawScores[player.uid] != 0)
      return Positioned(
        bottom: 0,
        right: 0,
        child: Container(
          transform: Matrix4.translationValues(5, 9, 0),
          child: CircleAvatar(
            backgroundColor: Colors.limeAccent,
            radius: 10,
            child: Text("${state.drawScores[player.uid]}",
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
