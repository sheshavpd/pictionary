import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pictionary/blocs/game/game.dart';
import 'package:pictionary/repositories/game_repository.dart';
import 'package:pictionary/utils/utils.dart';

class AnswerHint extends StatelessWidget {
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
