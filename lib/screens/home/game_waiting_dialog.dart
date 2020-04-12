import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pictionary/blocs/game/game.dart';
import 'package:pictionary/blocs/game/game_bloc.dart';
import 'package:pictionary/blocs/game/game_event.dart';
import 'package:pictionary/widgets/game_button.dart';


class GameWaitingDialog extends StatelessWidget {
  final GameBloc gameBloc;

  GameWaitingDialog({@required this.gameBloc});

  _dialogContent(BuildContext context) {
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
                colorFilter: ColorFilter.mode(Colors.white, BlendMode.dstATop)),
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
                Text(
                  "Please wait, looking for other online players..",
                  textAlign: TextAlign.center,
                  softWrap: true,
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
                ),
                SizedBox(height: 15.0),
                Align(
                  alignment: Alignment.bottomRight,
                  child: FancyButton(
                    onPressed: () {
                      gameBloc.add(GameExited());
                    },
                    size: 30,
                    color: Colors.red,
                    child: Text(
                      "Exit",
                      style: TextStyle(color: Colors.white, fontSize: 17),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          left: _Consts.padding,
          right: _Consts.padding,
          child: CircleAvatar(
            backgroundColor: Colors.deepPurple,
            radius: _Consts.avatarRadius,
            child: Image(
                height: 40.0,
                width: 40.0,
                image: AssetImage("assets/images/group.png")),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
        child: Container(
          color: Color.fromARGB(160, 0, 0, 0),
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_Consts.padding),
            ),
            elevation: 0.0,
            backgroundColor: Colors.transparent,
            child: _dialogContent(context),
          ),
        )
    );
  }
}

class _Consts {
  _Consts._();

  static const double padding = 10.0;
  static const double avatarRadius = 40.0;
}
