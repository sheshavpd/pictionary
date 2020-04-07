import 'package:flutter/foundation.dart';
import 'package:equatable/equatable.dart';
import 'package:pictionary/models/Player.dart';

class GameAnswer extends Equatable {
  final String answer;
  final bool correctAnswer;
  final Player fromPlayer;

  GameAnswer(
      {@required this.answer,
        @required this.correctAnswer,
        @required this.fromPlayer,
      });


  @override
  // TODO: implement props
  List<Object> get props =>
      [this.answer, this.correctAnswer];
}
