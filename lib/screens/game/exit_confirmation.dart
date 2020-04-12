import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pictionary/blocs/game/game.dart';
import 'package:pictionary/widgets/game_button.dart';

class ExitConfirmationDialog extends StatelessWidget {
  final BuildContext gameContext;

  const ExitConfirmationDialog({Key key, @required this.gameContext}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Confirmation", style: TextStyle(fontWeight: FontWeight.bold),),
      content: Text("Are you sure you want to exit the game?"),
      actions: <Widget>[
        // usually buttons at the bottom of the dialog
        FancyButton(
          size: 20,
          color: Theme.of(context).primaryColor,
          child: Text("No", style: TextStyle(color: Colors.white),),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        FancyButton(
          size: 20,
          color: Colors.red,
          child: Text("Exit", style: TextStyle(color: Colors.white)),
          onPressed: () {
            BlocProvider.of<GameBloc>(gameContext).add(GameExited());
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}