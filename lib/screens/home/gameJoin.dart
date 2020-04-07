import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pictionary/blocs/game/game.dart';
import 'package:pictionary/widgets/game_button.dart';

class GameJoinDialog extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();
  final GameBloc gameBloc;
  GameJoinDialog({@required this.gameBloc});

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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width: 150,
                      child: TextField(
                        autofocus: true,
                        autocorrect: false,decoration: InputDecoration(
                          hintText: 'Enter room ID'
                      ),
                        controller: _controller,
                        style: TextStyle(
                          fontSize: 17.0,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Material(
                      color: Colors.transparent,
                      child: ClipOval(
                        child: IconButton(
                          onPressed: () async {
                            _controller.text = (await Clipboard.getData("text/plain")).text;
                          },
                          icon: Icon(Icons.content_paste, size: 18),
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(height: 24.0),
                FancyButton(
                  onPressed: () {
                    if(_controller.text == '')
                      return;
                    gameBloc.add(GameJoinRequested(_controller.text));
                    Navigator.of(context).pop(); // To close the dialog
                  },
                  size: 30,
                  color: Colors.deepPurpleAccent,
                  child: Text(
                    "Join Room",
                    style: TextStyle(color: Colors.white, fontSize: 17),
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
                image: AssetImage("assets/images/join.png")),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_Consts.padding),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: _dialogContent(context),
    );
  }
}

class _Consts {
  _Consts._();

  static const double padding = 16.0;
  static const double avatarRadius = 40.0;
}
