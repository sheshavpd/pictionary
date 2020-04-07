import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:pictionary/common/pretty_print.dart';

import '../utils/utils.dart';
import 'package:equatable/equatable.dart';

class Player extends Equatable {
  final String nick;
  final String imgURL;
  final String uid;

  final int currentScore;
  final int totalScore;
  final int drawScore; //Score of one draw.

  Player(
      {@required this.uid,
      @required this.nick,
      @required this.imgURL,
      @required this.currentScore,
      this.drawScore,
      @required this.totalScore});

  static Player fromJSON(Map pJsonMap) {
    return Player(
        uid: pJsonMap['uid'],
        nick: pJsonMap['nick'],
        imgURL: pJsonMap['avatar'],
        currentScore: pJsonMap['score'],
        drawScore: 0,
        totalScore: pJsonMap['totalScore']);
  }

  Player copyWith(
      {String nick,
      String imgURL,
      String uid,
        int drawScore,
      int currentScore,
      int totalScore}) {
    return Player(
      uid: uid ?? this.uid,
      imgURL: imgURL ?? this.imgURL,
      nick: nick ?? this.nick,
      currentScore: currentScore ?? this.currentScore,
      drawScore: drawScore ?? this.drawScore,
      totalScore: totalScore ?? this.totalScore,
    );
  }

  @override
  // TODO: implement props
  List<Object> get props =>
      [this.uid, this.nick, this.imgURL, this.currentScore, this.totalScore, this.drawScore];

  @override
  String toString() {
    return prettyPrint({
      'uid':  this.uid,
      'nick':  this.nick,
      'imgURL':  this.imgURL,
      'currentScore':  this.currentScore,
      'drawScore':  this.drawScore,
      'totalScore':  this.totalScore
    });
  }
}
