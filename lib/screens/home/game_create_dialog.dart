import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pictionary/blocs/game/game.dart';
import 'package:pictionary/blocs/game/game_bloc.dart';
import 'package:pictionary/blocs/game/game_event.dart';
import 'package:pictionary/utils/helpers.dart';
import 'package:pictionary/widgets/game_button.dart';


class GameCreationDialog extends StatelessWidget {
  final String roomID;
  final GameBloc gameBloc;

  GameCreationDialog({@required this.roomID, @required this.gameBloc});

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
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  alignment: WrapAlignment.center,
                  children: <Widget>[
                    Text(
                      "Room ID: ${this.roomID}",
                      style: TextStyle(
                        fontSize: 17.0,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Material(
                      color: Colors.transparent,
                      child: ClipOval(
                        child: IconButton(
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: this.roomID));
                            BotToast.showText(text: "Copied!",
                                duration: Duration(seconds: 2));
                          },
                          icon: Icon(Icons.content_copy, size: 18),
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(height: 5.0),
                Text(
                  "Waiting for players to join..",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
                ),
                SizedBox(height: 16.0),
                FancyButton(
                  onPressed: () {
                    shareGameInvitation(roomID);
                  },
                  size: 30,
                  color: Colors.deepPurpleAccent,
                  child: Text(
                    "Share invitation link",
                    style: TextStyle(color: Colors.white, fontSize: 17),
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
