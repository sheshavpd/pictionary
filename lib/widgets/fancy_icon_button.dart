import 'package:flutter/material.dart';
import 'package:pictionary/widgets/game_button.dart';

class FancyIconButton extends StatelessWidget {
  final Color color;
  final Icon icon;
  final Function onPressed;

  const FancyIconButton({Key key, this.color, this.icon, this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FancyButton(
      child: Container(
        constraints: BoxConstraints(minWidth: 15, minHeight: 15),
        alignment: Alignment.center,
        child: icon,
      ),
      color: color,
      onPressed: onPressed,
      size: 20,
    );
  }
}
