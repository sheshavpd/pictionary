import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'package:pictionary/blocs/game/game.dart';
import 'package:pictionary/blocs/game/game_sv_events.dart';
import 'package:pictionary/models/stroke.dart';
import 'package:pictionary/repositories/AppSocket.dart';
import 'package:pictionary/repositories/data_providers/game_msg_listener.dart';
import 'package:rxdart/rxdart.dart';
import 'canvas.dart';

class CanvasBloc extends Bloc<CanvasEvent, CanvasState> {
  final _socket = AppSocket();
  final _addedStrokePoints = PublishSubject<StrokePoint>();
  final GameBloc _gameBloc;
  StreamSubscription<List<StrokePoint>> _newStrokePointsSubscription;
  StreamSubscription<String> _socketSubscription;
  StreamSubscription<GameState> _gameStateSubscription;

  CanvasBloc(this._gameBloc) {
    _socketSubscription = _socket.message.listen(_onMessageReceived);
    _newStrokePointsSubscription = _addedStrokePoints
        .bufferTime(Duration(milliseconds: 500))
        .listen((strokePoints) {
      if (strokePoints.length > 0) {
        add(SendStrokePoints(strokePoints: strokePoints));
      }
    });
    _gameStateSubscription = _gameBloc.listen((state) {
      /*if (state is GamePlaying &&
          state.gameDetails.state == GameStateConstants.DRAWING)
        add(ClearCanvas());*/
    });
  }

  void _onMessageReceived(String message) {
    Map msg;
    try {
      msg = json.decode(message);
    } catch (_) {
      return;
    }
    if (msg['type'] == GameEventConstants.STROKE) {
      List<StrokePoint> strokePoints = (msg['strokePoints'] as List)
          .map((strokePointMap) => StrokePoint.fromJSON(strokePointMap))
          .toList();
      add(StrokePointsReceived(strokePoints: strokePoints));
      return;
    }
    if (msg['type'] == GameEventConstants.CLEAR_BOARD) {
      add(ClearCanvas());
      return;
    }
    if (msg['type'] == GameEventConstants.CHOOSING_STARTED) {
      add(ClearCanvas());
      return;
    }
  }

  @override
  CanvasState get initialState =>
      CanvasState(strokePoints: [], strokeSize: 2, color: Colors.black.value, erasing: false, strokeSessions: []);

  @override
  Stream<CanvasState> mapEventToState(
    CanvasEvent event,
  ) async* {
    if (event is DrawPropsChanged) {
      yield state.copyWith(color: event.color, strokeSize: event.strokeSize, erasing: event.erasing);
    }

    if (event is StrokePointsReceived) {
      yield state.copyWith(
          strokePoints: state.strokePoints + event.strokePoints);
    }

    if (event is AddStrokeOffset) {
      _addedStrokePoints.add(StrokePoint(
          fromPoint: event.from,
          toPoint: event.to,
          color: state.erasing ? Colors.white.value: state.color,
          size: state.strokeSize));
    }

    if (event is AddStrokeSession) {
      yield state.copyWith(strokeSessions: state.strokeSessions + [event.strokeSession]);
    }

    if (event is ClearCanvas) {
      yield state.copyWith(strokePoints: [], strokeSessions: [], erasing: false);
    }

    if (event is ClearStrokeSessions) {
      yield state.copyWith(strokeSessions: [], erasing: false);
      final currentState = _gameBloc.state;
      if (currentState is GamePlaying)
        _socket.sendMessage(json.encode({
          'type': GameEventConstants.CLEAR_BOARD,
          'payload': {
            'gameUID': currentState.gameDetails.gameUID
          }
        }));
    }

    if (event is SendStrokePoints) {
      final currentState = _gameBloc.state;
      if (currentState is GamePlaying)
        _socket.sendMessage(json.encode({
          'type': GameEventConstants.STROKE,
          'payload': {
            'strokePoints': (event.strokePoints.map((sp)=>sp.toMap())).toList(),
            'gameUID': currentState.gameDetails.gameUID
          }
        }));
    }
  }

  @override
  Future<void> close() {
    _gameStateSubscription.cancel();
    _newStrokePointsSubscription.cancel();
    _socketSubscription.cancel();
    return super.close();
  }
}
