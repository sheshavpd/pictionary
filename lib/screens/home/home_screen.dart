import 'package:pictionary/common/app_logger.dart';
import 'package:pictionary/models/User.dart';
import 'package:pictionary/screens/game/game_screen.dart';

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
    final userToken = BlocProvider.of<AuthenticationBloc>(context).userToken;
    final gameRepository = GameRepository(User.fromToken(userToken));
    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: TopBar(),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: RepositoryProvider<GameRepository>(
        create: (_) => gameRepository,
        child: BlocProvider<GameBloc>(
          create: (_) => GameBloc(gameRepository),
          child: BlocBuilder<GameBloc, GameState>(
            condition: (previous, present){
                if(previous is GamePlaying && present is GamePlaying)
                  return true; //Some in-game state changed.
                else return previous.runtimeType != present.runtimeType;
            },
            builder: (context, state) {
              if(state is GamePlaying && state.gameDetails.players.length > 1)
                return GameScreen();
              else return GameScreen();
            }
          ),
        ),
      ),
    );
  }
}

class TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.centerRight, child: OnlineIndicator());
  }
}

class _Home extends StatelessWidget {
  _createPlayBtn(BuildContext context) {
    return _IconButton(
      isLoading: (state) => state is GameJoining,
      imagePath: 'assets/images/draw.png',
      buttonText: 'Play now',
      color: Colors.purple,
      onPressed: () {
        //Only if the state is 'GameNotPlaying' allow to request new game.
        //Because he might be GameCreating, GameJoining etc.
        /*if (BlocProvider.of<GameBloc>(context).state is GameNotPlaying)
          BlocProvider.of<GameBloc>(context).add(GameCreateRequested());*/

        showDialog(
          barrierDismissible: true,
          context: context,
          builder: (BuildContext context) =>
              GameJoinDialog(gameBloc: BlocProvider.of<GameBloc>(context)),
        );
        print('pressed');
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
        if (BlocProvider.of<GameBloc>(context).state is GameNotPlaying)
          BlocProvider.of<GameBloc>(context).add(GameCreateRequested());
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
              ? GameCreationDialog(
                  roomID: state.gameRoomNick, gameBloc: BlocProvider.of<GameBloc>(context))
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
                    margin: EdgeInsets.only(top: 130, bottom: 30),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Image(
                            width: 250.0,
                            image: AssetImage(
                                'assets/images/pictionary_text.png')),
                        Column(
                          children: <Widget>[
                            _createPlayBtn(context),
                            SizedBox(height: 20),
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
}

class OnlineIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final AuthenticationBloc authenticationBloc =
        BlocProvider.of<AuthenticationBloc>(context);
    return BlocBuilder<ConnectionBloc, AppConnectionState>(
      builder: (BuildContext context, AppConnectionState state) {
        return GestureDetector(
          child: Container(
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
          ),
          onDoubleTap: () {
            authenticationBloc.add(LoggedOut());
          },
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
