import 'package:flutter/material.dart';

class GameSimilarityNotif extends StatelessWidget {
  final String similarityText;

  const GameSimilarityNotif({Key key, this.similarityText}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(10),
        color: Colors.black,
        child: Text(similarityText, style: TextStyle(color: Colors.white),));
  }
}
