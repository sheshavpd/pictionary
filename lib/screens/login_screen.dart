import 'package:flutter/cupertino.dart';

import '../blocs/authentication/authentication.dart';
import '../blocs/login/login.dart';
import '../repositories/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import '../widgets/game_button.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<LoginBloc>(
      create: (context) {
        return LoginBloc(
          authenticationBloc: BlocProvider.of<AuthenticationBloc>(context),
          userRepository: RepositoryProvider.of<UserRepository>(context),
        );
      },
      child: LoginForm(),
    );
  }
}

class LoginForm extends StatefulWidget {
  LoginForm({Key key}) : super(key: key);

  @override
  _LoginFormState createState() => new _LoginFormState();
}

class _LoginFormState extends State<LoginForm>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  AnimationController _containerAnimationController;
  Animation<double> _containerAnimation;
  @override
  void initState() {
    super.initState();
    _containerAnimationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 2000));
    _containerAnimation = Tween(begin: -5.0, end: 5.0).animate(_containerAnimationController);

    _containerAnimationController.repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    timeDilation = 1.3;
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: true,
      body: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (overscroll) {
            overscroll.disallowGlow();
          },
          child: BlocListener<LoginBloc, LoginState>(
            listener: (context, state) {
              if (state is LoginFailure) {
                Scaffold.of(context).removeCurrentSnackBar();
                Scaffold.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${state.error}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: SizedBox.expand(
              child: Container(
                color: Colors.black,
                padding: EdgeInsets.only(top: 75, bottom: 40),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        AnimatedBuilder(
                            animation: _containerAnimation,
                            builder: (context, index) {
                              return Container(
                                  transform: Matrix4.translationValues(0,
                                      _containerAnimation.value, 0.0),
                                  child: Image(
                                      height: 80.0,
                                      width: 80.0,
                                      image: AssetImage(
                                          'assets/images/qg_glow.png')));
                            }),
                        Image(
                            width: 230.0,
                            image:
                                AssetImage('assets/images/qg_text_glow.png')),
                      ],
                    ),
                    const _LoginBtnWidget()
                  ],
                ),
              ),
            ),
          )),
    );
  }

  @override
  void dispose() {
    _containerAnimationController.dispose();
    super.dispose();
  }
}

class _LoginBtnWidget extends StatelessWidget {
  const _LoginBtnWidget();

  @override
  Widget build(BuildContext context) {
    final loginBloc = BlocProvider.of<LoginBloc>(context);
    return FancyButton(
      child: BlocBuilder<LoginBloc, LoginState>(builder: (context, state) {
        if (state is LoginLoading) {
          return SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ));
        } else {
          return Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.ideographic,
            children: <Widget>[
              Icon(
                FontAwesomeIcons.google,
                color: Colors.white,
                size: 20.0,
              ),
              Text(
                " Sign in with Google",
                style: TextStyle(color: Colors.white, fontSize: 20.0),
              )
            ],
          );
        }
      }),
      size: 30,
      color: Theme.of(context).accentColor,
      onPressed: () {
        if (!(loginBloc.state is LoginLoading)) loginBloc.add(LoginToGoogle());
      },
    );
  }
}
