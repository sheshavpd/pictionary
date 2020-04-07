import 'dart:async';
import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pictionary/blocs/game/game.dart';
import 'package:pictionary/models/game_answer.dart';

class GameMessages extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
          maxWidth: 150,
          maxHeight: MediaQuery.of(context).size.height * 9 / 16),
      child: _MessageList(),
    );
  }
}

class ScalingMessage extends StatefulWidget {
  final Widget child;

  const ScalingMessage({Key key, this.child}) : super(key: key);

  @override
  _ScalingMessageState createState() => _ScalingMessageState();
}

class _ScalingMessageState extends State<ScalingMessage>
    with
        TickerProviderStateMixin,
        AutomaticKeepAliveClientMixin<ScalingMessage> {
  AnimationController _controller;
  Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    print("re-init");
    _controller = AnimationController(
        duration: const Duration(milliseconds: 500),
        vsync: this,
        value: 0.1,
        upperBound: 1);
    _animation =
        CurvedAnimation(parent: _controller, curve: Curves.bounceInOut);
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ScaleTransition(
        scale: _animation, alignment: Alignment.center, child: widget.child);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

class _MessageList extends StatefulWidget {
  @override
  _MessageListState createState() => _MessageListState();
}

class _MessageListState extends State<_MessageList> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    /*Timer.periodic(Duration(milliseconds: 2000), (timer) {
      setState(() {
        messages.insert(0, {
          'name': 'testName',
          'msg': 'Hello worldd ${DateTime.now().second}',
          'key': DateTime.now().millisecondsSinceEpoch
        });
        _listKey.currentState.insertItem(0);
      });
    });*/
  }

  _buildMessageItem(List<GameAnswer> messages, context, index) {
    final currentAnswer = messages.elementAt(index).correctAnswer;
    return SizedBox(
      /*key: ValueKey(messages[index]['key']),*/
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: EdgeInsets.all(3),
          padding: EdgeInsets.all(3),
          decoration: BoxDecoration(
              color: currentAnswer ? Colors.green : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Color.fromARGB(40, 0, 0, 0),
                  blurRadius: 1.0, // has the effect of softening the shadow
                  spreadRadius: 0.2, // has the effect of extending the shadow
                  offset: Offset(
                    0.0, // horizontal, move right 10
                    0.0, // vertical, move down 10
                  ),
                )
              ],
              borderRadius: BorderRadius.circular(3)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(messages.elementAt(index).answer,
                  style: TextStyle(
                      fontSize: 12,
                      color: currentAnswer ? Colors.white : Colors.black)),
              Text(messages.elementAt(index).fromPlayer != null?messages.elementAt(index).fromPlayer.nick:"Couldn't fetch name",
                  style: TextStyle(
                      fontSize: 12,
                      color: currentAnswer
                          ? Colors.green.shade900
                          : Colors.deepPurple)),
            ],
          ),
        ),
      ),
    );
  }

  bool reRenderIf(GameState previous, GameState present) {
    if (previous is GamePlaying && present is GamePlaying)
      return previous.answers != present.answers;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GameBloc, GameState>(
        listenWhen: reRenderIf,
        buildWhen: reRenderIf,
        listener: (context, state) {
          if ((state as GamePlaying).answers != null &&
              (state as GamePlaying).answers.length > 0)
            _listKey.currentState.insertItem(0);
        },
        builder: (context, state) {
          final messages = (state as GamePlaying).answers ?? [];
          return AnimatedList(
              padding: EdgeInsets.only(top: 0),
              key: _listKey,
              reverse: true,
              physics: NeverScrollableScrollPhysics(),
              initialItemCount: messages.length,
              itemBuilder: (context, index, animation) {
                return SizeTransition(
                    /*key: ValueKey(messages[index]['key']),*/
                    sizeFactor: animation,
                    child: _buildMessageItem(messages, context, index));
              });
        });
  }
}
