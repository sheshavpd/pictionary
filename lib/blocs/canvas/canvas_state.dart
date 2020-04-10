import 'package:flutter/foundation.dart';
import 'package:pictionary/models/stroke.dart';
import 'package:equatable/equatable.dart';
import 'package:pictionary/models/stroke_session.dart';

/*
abstract class CanvasState extends Equatable {
  const CanvasState();
  @override
  List<Object> get props => [];
}
*/

class CanvasState extends Equatable {
  final List<StrokePoint> strokePoints;
  final List<StrokeSession> strokeSessions;
  final int color;
  final double strokeSize;
  final String drawingStateID;
  final bool erasing;
  const CanvasState({ @required this.strokePoints, @required  this.color, @required  this.strokeSize, this.drawingStateID, this.erasing, @required this.strokeSessions });
  @override
  String toString() => 'CanvasState';

  CanvasState copyWith({List<StrokePoint> strokePoints, List<StrokeSession> strokeSessions, int color, double strokeSize, String drawingStateID, bool erasing}){
      return CanvasState(
        strokePoints: strokePoints ?? this.strokePoints,
        color: color ?? this.color,
        strokeSize: strokeSize ?? this.strokeSize,
        drawingStateID: drawingStateID ?? this.drawingStateID,
        erasing: erasing ?? this.erasing,
        strokeSessions: strokeSessions ?? this.strokeSessions,
      );
  }
  @override
  List<Object> get props => [this.color, this.strokeSize, this.strokePoints, this.strokeSessions, this.erasing];
}
