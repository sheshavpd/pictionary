import 'package:flutter/material.dart';

class MessageBubble extends CustomPainter {

  Paint painter;

  MessageBubble({Color color}) {

    painter = Paint()
      ..color = color ?? Colors.purpleAccent
      ..style = PaintingStyle.fill;

  }

  @override
  void paint(Canvas canvas, Size size) {

    final space = size.width;
    var path = Path();

    path.lineTo(0, space);
    path.lineTo(space, space);
    path.arcToPoint(Offset(0, 0), radius: Radius.circular(space), largeArc: false, rotation: 0.6, clockwise: true, );
    path.close();
    canvas.drawShadow(path.shift(Offset(2, -1)), Colors.black.withAlpha(80), 1.0, true);

    canvas.drawPath(path, painter);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}