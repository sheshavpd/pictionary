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

  Player(
      {@required this.uid,
      @required this.nick,
      @required this.imgURL,
      @required this.currentScore,
      @required this.totalScore});

  static Player fromJSON(Map pJsonMap) {
    return Player(
        uid: pJsonMap['uid'],
        nick: pJsonMap['nick'],
        imgURL: pJsonMap['avatar'],
        currentScore: pJsonMap['score'] ?? 0,
        totalScore: pJsonMap['totalScore'] ?? 0);
  }

  Player copyWith(
      {String nick,
      String imgURL,
      String uid,
      int currentScore,
      int totalScore}) {
    return Player(
      uid: uid ?? this.uid,
      imgURL: imgURL ?? this.imgURL,
      nick: nick ?? this.nick,
      currentScore: currentScore ?? this.currentScore,
      totalScore: totalScore ?? this.totalScore,
    );
  }

  @override
  // TODO: implement props
  List<Object> get props =>
      [this.uid, this.nick, this.imgURL, this.currentScore, this.totalScore];

  @override
  String toString() {
    return prettyPrint({
      'uid':  this.uid,
      'nick':  this.nick,
      'imgURL':  this.imgURL,
      'currentScore':  this.currentScore,
      'totalScore':  this.totalScore
    });
  }
}
