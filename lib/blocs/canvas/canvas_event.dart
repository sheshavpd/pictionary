import 'package:flutter/material.dart';
import 'package:pictionary/models/stroke.dart';
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
import 'package:pictionary/models/stroke_session.dart';

abstract class CanvasEvent extends Equatable {
  const CanvasEvent();
  @override
  List<Object> get props => [];
}

class DrawPropsChanged extends CanvasEvent {
  final int color;
  final double strokeSize;
  final bool erasing;
  const DrawPropsChanged({this.color, this.strokeSize, this.erasing});
  @override
  String toString() => 'DrawPropsChanged';
  @override
  List<Object> get props => [color, strokeSize, erasing];
}

class AddStrokeOffset extends CanvasEvent {
  final Offset from;
  final Offset to;
  const AddStrokeOffset({@required this.from, @required this.to});
  @override
  String toString() => 'AddStrokeOffset';
  @override
  List<Object> get props => [from, to];
}

class AddStrokeSession extends CanvasEvent {
  final StrokeSession strokeSession;
  const AddStrokeSession({@required this.strokeSession});
  @override
  String toString() => 'AddStrokeSession';
  @override
  List<Object> get props => [strokeSession];
}

class ClearStrokeSessions extends CanvasEvent {
  const ClearStrokeSessions();
  @override
  String toString() => 'ClearStrokeSessions';
}

class ClearCanvas extends CanvasEvent {
  const ClearCanvas();
  @override
  String toString() => 'ClearCanvas';
}

class SendStrokePoints extends CanvasEvent {
  final List<StrokePoint> strokePoints;
  const SendStrokePoints({@required this.strokePoints});
  @override
  String toString() => 'SendStrokePoints';
  @override
  List<Object> get props => [strokePoints];
}

class StrokePointsReceived extends CanvasEvent {
  final List<StrokePoint> strokePoints;
  const StrokePointsReceived({@required this.strokePoints});
  @override
  String toString() => 'StrokePointsReceived';
  @override
  List<Object> get props => [strokePoints];
}
