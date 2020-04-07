import 'dart:async';

import 'package:flutter/material.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';
import 'package:pictionary/common/app_logger.dart';

class GameTimeout extends StatefulWidget {
  final int startTimeMs;
  final int targetTimeMs;
  final Color color;
  final Widget Function(String secondsRemaining) center;

  GameTimeout(
      {Key key,
      @required this.targetTimeMs,
      @required this.startTimeMs,
      this.center,
      this.color})
      : super(key: key) {}

  @override
  State<StatefulWidget> createState() => _GameTimeoutState();
}

class _GameTimeoutState extends State<GameTimeout>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  int _timeDiff = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _animationController = AnimationController(
      vsync: this,
    );
    _animationController.addListener(() => setState(() {
          _timeDiff =
              (widget.targetTimeMs - DateTime.now().millisecondsSinceEpoch);
        }));
    startProgressing();
  }

  void startProgressing() {
    _timeDiff = (widget.targetTimeMs - DateTime.now().millisecondsSinceEpoch);
    _animationController.duration =
        Duration(milliseconds: _timeDiff <= 0 ? 0 : _timeDiff);
    _animationController.reset();
    _animationController.forward();
  }

  @override
  void didUpdateWidget(GameTimeout oldWidget) {
    super.didUpdateWidget(oldWidget);
    startProgressing();
  }

  double percentTimeLeft() {
    return 1 -
        (DateTime.now().millisecondsSinceEpoch - widget.startTimeMs) /
            (widget.targetTimeMs - widget.startTimeMs);
  }

  @override
  Widget build(BuildContext context) {
    final remainingSeconds =
        ((widget.targetTimeMs - DateTime.now().millisecondsSinceEpoch) / 1000)
            .round();
    return _timeDiff < 0
        ? SizedBox.expand()
        : LiquidLinearProgressIndicator(
            value: percentTimeLeft(),
            // Defaults to 0.5.
            valueColor: AlwaysStoppedAnimation(
                widget.color ?? Theme.of(context).primaryColorDark),
            // Defaults to the current Theme's accentColor.
            backgroundColor: Colors.transparent,
            // Defaults to the current Theme's backgroundColor.
            borderColor: Colors.transparent,

            borderWidth: 0,
            direction: Axis.horizontal,
            // The direction the liquid moves (Axis.vertical = bottom to top, Axis.horizontal = left to right). Defaults to Axis.horizontal.
            center: widget.center != null
                ? widget
                    .center('${remainingSeconds < 0 ? 0 : remainingSeconds}')
                : SizedBox.shrink(),
          );
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }
}
