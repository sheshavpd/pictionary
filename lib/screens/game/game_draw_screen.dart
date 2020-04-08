import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pictionary/blocs/game/game.dart';
import 'package:pictionary/screens/game/game_messages.dart';
import 'package:pictionary/screens/game/game_timeout.dart';

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
      children: <Widget>[
        WriteScreen(),
        _DrawOverlays()
      ],
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
    return IgnorePointer(
      ignoring: true,
      child: Stack(
        children: <Widget>[
          Container(
            height: _HEADER_HEIGHT,
            child: GameTimeout(startTimeMs: cState.gameDetails.startTimeMs, targetTimeMs: cState.gameDetails.targetTimeMs,
              center: (String secondsRemaining){
                return Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: EdgeInsets.only(left: 10),
                      child: Text("$secondsRemaining",
                        style: TextStyle(color: Colors.orange.shade900),
                      ),
                    ));
              },
              color: Theme.of(context).primaryColor.withAlpha(60),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: _HEADER_HEIGHT + 10),
            alignment: Alignment.topCenter,
            child: Opacity(
              opacity: 0.7,
              child: AnswerHint(),
            ),
          ),
          Positioned(
              right: 0,
              bottom: 0,
              top:0,
              child: GameMessages()),
          Positioned(
            left:5,
            bottom:5,
            child: Text("Draw in landscape orientation", style: TextStyle(fontSize: 13, color: Colors.grey),)
          )
        ],
      ),
    );
  }
}

class KanjiPainter extends ChangeNotifier implements CustomPainter {
  Color strokeColor;
  var strokes = new List<List<Offset>>();

  KanjiPainter(this.strokeColor);

  bool hitTest(Offset position) => null;

  void startStroke(Offset position) {
    print("startStroke");
    strokes.add([position]);
    notifyListeners();
  }

  void appendStroke(Offset position) {
    print("appendStroke");
    var stroke = strokes.last;
    stroke.add(position);
    notifyListeners();
  }

  void endStroke() {
    notifyListeners();
  }

  @override
  void paint(Canvas canvas, Size size) {
    print("paint!");
    var rect = Offset.zero & size;
    Paint fillPaint = new Paint();
    fillPaint.color = Colors.yellow[100];
    fillPaint.style = PaintingStyle.fill;
    canvas.drawRect(rect, fillPaint);

    Paint strokePaint = new Paint();
    strokePaint.color = Colors.black;
    strokePaint.style = PaintingStyle.stroke;

    for (var stroke in strokes) {
      Path strokePath = new Path();
      // Iterator strokeIt = stroke.iterator..moveNext();
      // Offset start = strokeIt.current;
      // strokePath.moveTo(start.dx, start.dy);
      // while (strokeIt.moveNext()) {
      //   Offset off = strokeIt.current;
      //   strokePath.addP
      // }
      strokePath.addPolygon(stroke, false);
      canvas.drawPath(strokePath, strokePaint);
    }
  }

  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
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

class WriteScreen extends StatefulWidget {
  @override
  _WriteScreenState createState() => new _WriteScreenState();
}

class _WriteScreenState extends State<WriteScreen> {
  GestureDetector touch;
  CustomPaint canvas;
  KanjiPainter kanjiPainter;

  void panStart(DragStartDetails details) {
    print(details.globalPosition);
    kanjiPainter.startStroke(details.globalPosition);
  }

  void panUpdate(DragUpdateDetails details) {
    print(details.globalPosition);
    kanjiPainter.appendStroke(details.globalPosition);
  }

  void panEnd(DragEndDetails details) {
    kanjiPainter.endStroke();
  }

  @override
  void initState() {
    super.initState();
    kanjiPainter = new KanjiPainter(const Color.fromRGBO(255, 255, 255, 1.0));
  }

  @override
  Widget build(BuildContext context) {
    touch = new GestureDetector(
      onPanStart: panStart,
      onPanUpdate: panUpdate,
      onPanEnd: panEnd,
    );

    canvas = new CustomPaint(
      painter: kanjiPainter,
      child: touch,
      // child: new Text("Custom Painter"),
      // size: const Size.square(100.0),
    );
    final width = MediaQuery.of(context).size.width;
    return SizedBox.expand(
      child: FittedBox(
        alignment: Alignment.center,
        fit: BoxFit.cover,
        child: Container(
          width: width,
          height: width*9/16,
          child: canvas,
          //color: Colors.red.withAlpha(60),
        ),
      ),
    );

    Container container = new Container(
        padding: new EdgeInsets.all(20.0),
        child: new ConstrainedBox(
            constraints: const BoxConstraints.expand(),
            child: new Card(
              elevation: 10.0,
              child: canvas,
            )));

    return new Scaffold(
      appBar: new AppBar(title: new Text("Draw!")),
      backgroundColor: const Color.fromRGBO(200, 200, 200, 1.0),
      body: container,
    );
  }
}


class _DrawCanvas extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return SizedBox.expand(
      child: FittedBox(
        alignment: Alignment.center,
        fit: BoxFit.cover,
        child: Container(
          width: width,
          height: width*9/16,
          //color: Colors.red.withAlpha(60),
        ),
      ),
    );
  }
}

