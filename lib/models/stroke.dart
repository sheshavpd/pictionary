import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pictionary/common/pretty_print.dart';

import '../utils/utils.dart';
import 'package:equatable/equatable.dart';

class StrokePoint extends Equatable {
  final int color;
  final double size;
  final Offset fromPoint;
  final Offset toPoint;
  StrokePoint({this.color, this.size, this.fromPoint, this.toPoint});

  static StrokePoint fromJSON(Map sJsonMap) {
    return StrokePoint(
        color: sJsonMap['color'],
        size: (sJsonMap['size'] as num).toDouble(),
        fromPoint: Offset(sJsonMap['from'][0], sJsonMap['from'][1]),
        toPoint: Offset(sJsonMap['to'][0], sJsonMap['to'][1]));
  }

  Map toMap() {
    return {
      'color':  color,
      'size': size,
      'from': [fromPoint.dx, fromPoint.dy],
      'to': [toPoint.dx, toPoint.dy],
    };
  }

  @override
  // TODO: implement props
  List<Object> get props =>
      [this.color, this.size, this.fromPoint, this.toPoint];

}
