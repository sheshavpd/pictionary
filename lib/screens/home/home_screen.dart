import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pictionary/models/User.dart';
import 'package:pictionary/screens/game/exit_confirmation.dart';
import 'package:pictionary/screens/game/game_screen.dart';
import 'package:pictionary/screens/home/game_waiting_dialog.dart';
import 'package:pictionary/widgets/placeholder_image.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../blocs/game/game.dart';
import '../../repositories/game_repository.dart';
import 'package:pictionary/screens/home/gameJoin.dart';
import '../../widgets/game_button.dart';

import '../../blocs/authentication/authentication.dart';
import '../../blocs/connection/connection.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'game_create_dialog.dart';

class _IconButton extends StatelessWidget {
  final String imagePath;
  final String buttonText;
  final Function onPressed;
  final Color color;
  final bool Function(GameState gameState) isLoading;

  const _IconButton(
      {Key key,
      @required this.onPressed,
      @required this.isLoading,
      this.imagePath,
      this.buttonText,
      this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<GameBloc, GameState>(
        listener: (context, state) {
          if (state is GameCreateFailed) {
            Scaffold.of(context).removeCurrentSnackBar();
            Scaffold.of(context).showSnackBar(
              SnackBar(
                content: Text('${state.failReason}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: FancyButton(
          child: Container(
            constraints: BoxConstraints(minWidth: 80, minHeight: 80),
            child: BlocBuilder<GameBloc, GameState>(builder: (context, state) {
              if (isLoading(state)) {
                return Center(
                  child: SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )),
                );
              } else {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image(
                        height: 60.0,
                        width: 60.0,
                        image: AssetImage(imagePath)),
                    Text(buttonText,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 16.0))
                  ],
                );
              }
            }),
          ),
          color: color,
          size: 30,
          onPressed: onPressed,
        ));
    ;
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen();

  @override
  Widget build(BuildContext context) {
    return _HomeProvider();
  }
}

class _HomeProvider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<GameRepository>(
      create: (ctx) => GameRepository(
          User.fromToken(BlocProvider.of<AuthenticationBloc>(ctx).userToken)),
      child: BlocProvider<GameBloc>(
        create: (ctx) => GameBloc(RepositoryProvider.of<GameRepository>(ctx)),
        child: _HomePresenter(),
      ),
    );
  }
}

class _HomePresenter extends StatelessWidget {
  Future<bool> _onBackPressed(BuildContext context) async {
    final _gameBloc = BlocProvider.of<GameBloc>(context);
    final state = _gameBloc.state;
    if (state is GamePlaying) {
      if (state.gameDetails.players.length <= 1)
        _gameBloc.add(GameExited());
      else
        showDialog(
          context: context,
          builder: (BuildContext ctx) {
            return ExitConfirmationDialog(gameContext: context);
          },
        );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameBloc, GameState>(condition: (previous, present) {
      if (previous is GamePlaying && present is GamePlaying)
        return true; //Some in-game state changed.
      else
        return previous.runtimeType != present.runtimeType;
    }, builder: (context, state) {
      return WillPopScope(
          child: Scaffold(
            extendBodyBehindAppBar: true,
            resizeToAvoidBottomPadding: false,
            body: Stack(
              children: <Widget>[
                Positioned.fill(
                    child: (state is GamePlaying &&
                            state.gameDetails.players.length > 1)
                        ? GameScreen()
                        : _Home()),
                TopBar()
              ],
            ),
          ),
          onWillPop: () async {
            return await _onBackPressed(context);
          });
    });
  }
}

class TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: true,
      child:
          Container(alignment: Alignment.topRight, child: OnlineIndicator()),
    );
  }
}

class _Home extends StatelessWidget {
  _createPlayBtn(BuildContext context) {
    return _IconButton(
      isLoading: (state) => state is GameJoiningPub,
      imagePath: 'assets/images/draw.png',
      buttonText: 'Play now',
      color: Colors.purple,
      onPressed: () {
        //Only if the state is 'GameNotPlaying' allow to request new game.
        //Because he might be GameCreating, GameJoining etc.
        if (BlocProvider.of<GameBloc>(context).state is GameNotPlaying)
          BlocProvider.of<GameBloc>(context).add(GameJoinPubRequested());
      },
    );
  }

  _createPrivateRoomBtn(BuildContext context) {
    return _IconButton(
      isLoading: (state) => state is GameCreating,
      imagePath: 'assets/images/group.png',
      buttonText: 'New Room',
      onPressed: () {
        //Only if the state is 'GameNotPlaying' allow to request new game.
        //Because he might be GameCreating, GameJoining etc.
        if (BlocProvider.of<GameBloc>(context).state is GameNotPlaying) {
          showDialog(
            context: context,
            builder: (BuildContext dialogCtx) {
              // return object of type Dialog
              return AlertDialog(
                title: Text(
                  "Enable audio in game?",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                content: Text(
                    "Audio communication is still in beta, and might cause unexpected issues. Do you want to enable it for this room?"),
                actions: <Widget>[
                  // usually buttons at the bottom of the dialog
                  FancyButton(
                    size: 20,
                    color: Theme.of(dialogCtx).primaryColor,
                    child: Text(
                      "No",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      BlocProvider.of<GameBloc>(context)
                          .add(GameCreateRequested(false));
                      Navigator.of(dialogCtx).pop();
                    },
                  ),
                  FancyButton(
                    size: 20,
                    color: Theme.of(dialogCtx).primaryColor,
                    child: Text("Yes", style: TextStyle(color: Colors.white)),
                    onPressed: () {
                      BlocProvider.of<GameBloc>(context)
                          .add(GameCreateRequested(true));
                      Navigator.of(dialogCtx).pop();
                    },
                  ),
                ],
              );
            },
          );
        }
      },
      color: Theme.of(context).primaryColor,
    );
  }

  _createJoinRoomBtn(BuildContext context) {
    return _IconButton(
      isLoading: (state) => state is GameJoining,
      imagePath: 'assets/images/join.png',
      buttonText: 'Join Room',
      color: Theme.of(context).primaryColorDark,
      onPressed: () {
        //Only if the state is 'GameNotPlaying' allow to request new game.
        //Because he might be GameCreating, GameJoining etc.
        if (!(BlocProvider.of<GameBloc>(context).state is GameNotPlaying))
          return;
        showDialog(
          barrierDismissible: true,
          context: context,
          builder: (_) =>
              GameJoinDialog(gameBloc: BlocProvider.of<GameBloc>(context)),
        );
      },
    );
  }

  Widget _gameCreationDialog(BuildContext context) {
    return BlocBuilder<GameBloc, GameState>(
      builder: (context, state) {
        return AnimatedSwitcher(
          duration: Duration(milliseconds: 200),
          child: state is GamePlaying && state.gameDetails.players.length <= 1
              ? (state.isPublic
                  ? GameWaitingDialog(
                      gameBloc: BlocProvider.of<GameBloc>(context))
                  : GameCreationDialog(
                      roomID: state.gameRoomNick,
                      gameBloc: BlocProvider.of<GameBloc>(context)))
              : SizedBox.shrink(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
            decoration: BoxDecoration(
              color: Colors.white,
              image: DecorationImage(
                image: AssetImage("assets/images/main_bg1.jpg"),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
                color: Color.fromARGB(220, 255, 255, 255),
                child: SizedBox.expand(
                  child: Container(
                    margin: EdgeInsets.only(top: 100, bottom: 30),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Image(
                            width: 250.0,
                            image: AssetImage(
                                'assets/images/pictionary_text.png')),
                        Column(
                          children: <Widget>[
                            _userInfo(context),
                            SizedBox(height: 10),
                            _createPlayBtn(context),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                _createPrivateRoomBtn(context),
                                SizedBox(width: 20),
                                _createJoinRoomBtn(context),
                              ],
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ))),
        _gameCreationDialog(context)
      ],
    );
  }

  _userInfo(BuildContext context) {
    final user = BlocProvider.of<GameBloc>(context).user;
    return GestureDetector(
      onTapUp: (_) {
        showDialog(
          context: context,
          builder: (BuildContext dialogCtx) {
            return AlertDialog(
              title: Text(
                "Hey ${user.nick}!",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: RichText(
                text: TextSpan(
                  text:
                      "Thanks for playing pictionary! Hope you're liking it. You can rate the app on ${Platform.isAndroid ? 'Play' : 'App'} store to support this ",
                  style: DefaultTextStyle.of(context).style,
                  children: <TextSpan>[
                    TextSpan(
                        text: 'ad free experience',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: '.'),
                  ],
                ),
              ),
              actions: <Widget>[
                // usually buttons at the bottom of the dialog
                FancyButton(
                  size: 20,
                  color: Theme.of(context).primaryColor,
                  child: Text(
                    "Rate App",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () async {
                    final url =
                        "https://play.google.com/store/apps/details?id=com.quarantinegames.pictionary";
                    if (await canLaunch(url)) {
                      launch(url);
                    } else {
                      BotToast.showText(
                          text: "Couldn't launch application",
                          duration: Duration(seconds: 3));
                    }
                    Navigator.of(dialogCtx).pop();
                  },
                ),
                FancyButton(
                  size: 20,
                  color: Colors.red,
                  child: Text("Logout", style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    BlocProvider.of<AuthenticationBloc>(context)
                        .add(LoggedOut());
                    Navigator.of(dialogCtx).pop();
                  },
                ),
              ],
            );
          },
        );
      },
      child: Column(
        children: <Widget>[
          Container(
              decoration: BoxDecoration(
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Color.fromARGB(50, 0, 0, 0),
                    blurRadius: 20.0,
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 30,
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: user.avatar ?? '',
                    placeholder: (context, url) => placeholderImage,
                    errorWidget: (context, url, error) => placeholderImage,
                  ),
                ),
              )),
          Opacity(
            opacity: 0.9,
            child: Container(
              transform: Matrix4.translationValues(0, -10, 0),
              decoration: BoxDecoration(
                  color: Colors.purple,
                  borderRadius: BorderRadius.circular(100)),
              padding: EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10),
              child: Text(
                "${user.nick}",
                style: TextStyle(color: Colors.white),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class OnlineIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectionBloc, AppConnectionState>(
      builder: (BuildContext context, AppConnectionState state) {
        if (state is ConnectionConnected) return SizedBox.shrink();
        return Container(
          margin: EdgeInsets.only(top: 40, right: 20),
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(30)),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Color.fromARGB(70, 0, 0, 0),
                  offset: Offset(1.0, 1.0),
                  blurRadius: 10.0,
                ),
              ],
              color: _colorForState(state)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(_iconForState(state), color: Colors.white, size: 18),
              Text(
                " ${state.presentableString()}",
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontFamily: "MostlyMono"),
              )
            ],
          ),
        );
      },
    );
  }

  Color _colorForState(AppConnectionState state) {
    if (state is ConnectionConnecting) return Colors.orange;
    if (state is ConnectionConnected) return Colors.lightGreen;
    if (state is ConnectionNotConnected) return Colors.red;
  }

  IconData _iconForState(AppConnectionState state) {
    if (state is ConnectionConnecting) return Icons.flight_takeoff;
    if (state is ConnectionConnected) return Icons.link;
    if (state is ConnectionNotConnected) return Icons.link_off;
  }
}

/*class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final AuthenticationBloc authenticationBloc =
        BlocProvider.of<AuthenticationBloc>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Container(
        child: Center(
            child: RaisedButton(
          child: Text('logout'),
          onPressed: () {
            authenticationBloc.dispatch(LoggedOut());
          },
        )),
      ),
    );
  }
}*/
