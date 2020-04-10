import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pictionary/blocs/canvas/canvas.dart';
import 'package:pictionary/blocs/game/game.dart';
import 'package:pictionary/models/stroke_session.dart';
import 'package:pictionary/screens/game/game_messages.dart';
import 'package:pictionary/screens/game/game_timeout.dart';
import 'package:pictionary/widgets/bar_color_picker.dart';
import 'package:pictionary/widgets/fancy_icon_button.dart';
import 'package:pictionary/widgets/game_button.dart';
import 'package:rxdart/rxdart.dart';

import 'answer_hint.dart';

class GameDrawScreen extends StatefulWidget {
  @override
  _GameDrawScreenState createState() => _GameDrawScreenState();
}

const _HEADER_HEIGHT = 40.0;

class _GameDrawScreenState extends State<GameDrawScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[_DrawCanvas(), _DrawOverlays()],
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }
}

class _DrawOverlays extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cState = BlocProvider.of<GameBloc>(context).state as GamePlaying;
    return Stack(
      children: <Widget>[
        IgnorePointer(
          ignoring: true,
          child: Stack(
            children: <Widget>[
              Container(
                height: _HEADER_HEIGHT,
                child: GameTimeout(
                  startTimeMs: cState.gameDetails.startTimeMs,
                  targetTimeMs: cState.gameDetails.targetTimeMs,
                  center: (String secondsRemaining) {
                    return Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: EdgeInsets.only(left: 10),
                          child: Text(
                            "$secondsRemaining",
                            style: TextStyle(color: Colors.orange.shade900),
                          ),
                        ));
                  },
                  color: Theme.of(context).primaryColor.withAlpha(60),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 10),
                alignment: Alignment.topCenter,
                child: Text("${cState.hint}",
                    style: TextStyle(
                        fontSize: 17,
                        color: Theme.of(context).primaryColorDark)),
              ),
              Positioned(right: 0, bottom: 0, top: 0, child: GameMessages()),
            ],
          ),
        ),
        Positioned(left: 5, bottom: 0, child: _CanvasSettings()),
      ],
    );
  }
}

class _CanvasSettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: 250),
      padding: EdgeInsets.all(5),
      transform: Matrix4.translationValues(0, 1, 0),
      decoration: BoxDecoration(
          color: Colors.indigo.shade50,
          border: Border.all(color: Colors.indigo.shade200, width: 1),
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10), topRight: Radius.circular(10))),
      margin: EdgeInsets.all(0),
      child: BlocBuilder<CanvasBloc, CanvasState>(
        condition: (oldState, newState) {
          return (oldState.color != newState.color ||
              oldState.strokeSize != newState.strokeSize ||
              oldState.erasing != newState.erasing);
        },
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              IgnorePointer(
                ignoring: state.erasing,
                child: Opacity(
                  opacity: state.erasing ? 0.5 : 1.0,
                  child: BarColorPicker(
                    colorListener: (color) {
                      BlocProvider.of<CanvasBloc>(context)
                          .add(DrawPropsChanged(color: color));
                    },
                    width: 200,
                    initialColor: Color(state.color),
                    cornerRadius: 10,
                    thumbRadius: 10,
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  FancyIconButton(
                    color: state.erasing
                        ? Colors.white
                        : Theme.of(context).accentColor,
                    icon: Icon(
                      FontAwesomeIcons.pencilAlt,
                      size: 14,
                      color: state.erasing
                          ? Theme.of(context).accentColor
                          : Colors.white,
                    ),
                    onPressed: () {
                      BlocProvider.of<CanvasBloc>(context)
                          .add(DrawPropsChanged(erasing: false));
                    },
                  ),
                  FancyIconButton(
                    color: state.erasing
                        ? Theme.of(context).accentColor
                        : Colors.white,
                    icon: Icon(FontAwesomeIcons.eraser,
                        size: 14,
                        color: state.erasing
                            ? Colors.white
                            : Theme.of(context).accentColor),
                    onPressed: () {
                      BlocProvider.of<CanvasBloc>(context)
                          .add(DrawPropsChanged(erasing: true));
                    },
                  ),
                  _StrokeSizeButton(strokeSize: 2, iconSize: 6),
                  _StrokeSizeButton(strokeSize: 5, iconSize: 10),
                  _StrokeSizeButton(strokeSize: 9, iconSize: 14),
                  FancyIconButton(
                    color: Colors.red,
                    icon: Icon(FontAwesomeIcons.broom,
                        size: 14, color: Colors.white),
                    onPressed: () {
                      BlocProvider.of<CanvasBloc>(context).add(ClearStrokeSessions());
                    },
                  )
                ],
              )
            ],
          );
        },
      ),
    );
  }
}

class _StrokeSizeButton extends StatelessWidget {
  final double strokeSize;
  final double iconSize;

  const _StrokeSizeButton({Key key, this.strokeSize, this.iconSize})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = BlocProvider.of<CanvasBloc>(context).state;
    return FancyIconButton(
      color: state.strokeSize != strokeSize
          ? Colors.white
          : Theme.of(context).accentColor,
      icon: Icon(FontAwesomeIcons.solidCircle,
          size: iconSize,
          color: state.strokeSize != strokeSize
              ? Theme.of(context).accentColor
              : Colors.white),
      onPressed: () {
        BlocProvider.of<CanvasBloc>(context)
            .add(DrawPropsChanged(strokeSize: strokeSize));
      },
    );
  }
}

class ScribblePainter extends ChangeNotifier implements CustomPainter {
  List<StrokeSession> strokeSessions;

  ScribblePainter(this.strokeSessions);

  bool hitTest(Offset position) => null;

  void rePaint() {
    notifyListeners();
  }

  @override
  void paint(Canvas canvas, Size size) {
    var rect = Offset.zero & size;
    Paint fillPaint = new Paint();
    fillPaint.color = Colors.white;
    fillPaint.style = PaintingStyle.fill;
    canvas.drawRect(rect, fillPaint);
    Paint strokePaint = new Paint();
    strokePaint.style = PaintingStyle.stroke;
    strokePaint.strokeCap = StrokeCap.round;

    for (final strokeSession in strokeSessions) {
      strokePaint.color = strokeSession.color;
      strokePaint.strokeWidth = strokeSession.size;
      Path strokePath = new Path();
      if (strokeSession.strokes.length > 0)
        strokePath.moveTo(strokeSession.strokes.elementAt(0).dx * size.width,
            strokeSession.strokes.elementAt(0).dy * size.height);

      for (final strokePoint in strokeSession.strokes) {
        strokePath.lineTo(
            strokePoint.dx * size.width, strokePoint.dy * size.height);
      }
      canvas.drawPath(strokePath, strokePaint);
    }
  }

  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }

  @override
  // TODO: implement semanticsBuilder
  get semanticsBuilder => null;

  @override
  bool shouldRebuildSemantics(CustomPainter oldDelegate) {
    // TODO: implement shouldRebuildSemantics
    return null;
  }
}

class _DrawCanvas extends StatefulWidget {
  @override
  _DrawCanvasState createState() => new _DrawCanvasState();
}

class _DrawCanvasState extends State<_DrawCanvas> {
  GestureDetector touch;
  CustomPaint canvas;
  ScribblePainter scribblePainter;
  final mouseSubject = PublishSubject<Offset>();

  double _canvasWidth = 0;
  double _canvasHeight = 0;

  Offset _prevOffset;

  StrokeSession _currentStrokeSession;

  void appendStroke(Offset position) {
    //Update current stroke session directly instead of notifying bloc, because updating might be delayed by adding event to Bloc.
    _currentStrokeSession.strokes.add(position);
    scribblePainter
        .rePaint(); //Just repaint here instead of notifying bloc. (Performance optimization)
  }

  void panStart(DragStartDetails details) {
    final startOffset = Offset(details.localPosition.dx / _canvasWidth,
        details.localPosition.dy / _canvasHeight);
    CanvasBloc canvasBloc = BlocProvider.of<CanvasBloc>(context);
    _currentStrokeSession = StrokeSession(
        [startOffset],
        canvasBloc.state.erasing ? Colors.white : Color(canvasBloc.state.color),
        canvasBloc.state.strokeSize);
    canvasBloc.add(AddStrokeSession(strokeSession: _currentStrokeSession));
    _prevOffset = null;
    mouseSubject.add(startOffset);
  }

  void panUpdate(DragUpdateDetails details) {
    mouseSubject.add(Offset(details.localPosition.dx / _canvasWidth,
        details.localPosition.dy / _canvasHeight));
  }

  StreamSubscription<Offset> _mouseMoveSubscription;

  @override
  void initState() {
    super.initState();
    final canvasBloc = BlocProvider.of<CanvasBloc>(context);
    scribblePainter = new ScribblePainter(canvasBloc.state.strokeSessions);
    _mouseMoveSubscription =
        mouseSubject.throttleTime(Duration(milliseconds: 20)).listen((offset) {
      appendStroke(offset);
      if (_prevOffset != null)
        canvasBloc.add(AddStrokeOffset(from: _prevOffset, to: offset));
      _prevOffset = offset;
    });
  }

  @override
  Widget build(BuildContext context) {
    touch = new GestureDetector(onPanStart: panStart, onPanUpdate: panUpdate);

    canvas = new CustomPaint(painter: scribblePainter, child: touch);
    _canvasWidth = MediaQuery.of(context).size.width;
    _canvasHeight = _canvasWidth * 9 / 16;
    return BlocListener<CanvasBloc, CanvasState>(
      condition: (oldState, newState) =>
          oldState.strokeSessions != newState.strokeSessions,
      listener: (context, state) {
        scribblePainter.strokeSessions = state.strokeSessions;
        scribblePainter.rePaint();
      },
      child: SizedBox.expand(
        child: FittedBox(
          alignment: Alignment.center,
          fit: BoxFit.cover,
          child: Container(
            width: _canvasWidth,
            height: _canvasHeight,
            child: canvas,
            //color: Colors.red.withAlpha(60),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _mouseMoveSubscription?.cancel();
    mouseSubject.close();
    super.dispose();
  }
}
