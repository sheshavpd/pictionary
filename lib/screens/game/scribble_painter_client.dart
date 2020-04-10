import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pictionary/blocs/canvas/canvas.dart';
import 'package:pictionary/models/stroke.dart';

class _ScribblePainterClient extends CustomPainter {
  final List<StrokePoint> strokePoints;

  _ScribblePainterClient(this.strokePoints);

  @override
  void paint(Canvas canvas, Size size) {
    Paint strokePaint = new Paint();
    strokePaint.color = Colors.black;
    strokePaint.strokeWidth = 3;
    strokePaint.style = PaintingStyle.stroke;
    strokePaint.strokeCap = StrokeCap.round;
    for (final strokePoint in strokePoints) {
      strokePaint.color = Color(strokePoint.color);
      strokePaint.strokeWidth = strokePoint.size;
      canvas.drawLine(
          Offset(strokePoint.fromPoint.dx * size.width,
              strokePoint.fromPoint.dy * size.height),
          Offset(strokePoint.toPoint.dx * size.width,
              strokePoint.toPoint.dy * size.height),
          strokePaint);
    }
  }

  @override
  bool shouldRepaint(_ScribblePainterClient oldDelegate) {
    return oldDelegate.strokePoints != strokePoints;
  }
}

class ScribbleClient extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CanvasBloc, CanvasState>(
      condition: (oldState, newState) => oldState.strokePoints != newState.strokePoints,
      builder: (context, state) {
        return CustomPaint(
          painter: _ScribblePainterClient(state.strokePoints),
        );
      },
    );
  }
}

