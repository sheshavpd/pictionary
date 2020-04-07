import 'dart:async';

import '../blocs/authentication/authentication.dart';
import '../models/User.dart';
import '../repositories/AppSocket.dart';
import '../repositories/user_repository.dart';
import 'package:flutter/material.dart';
/*import 'package:flare_flutter/flare_actor.dart';
import 'package:camera/camera.dart';*/
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
//import 'package:flutter_sound/flutter_sound.dart';

import '../AppConstants.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen();

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthenticationBloc, AuthenticationState>(
      listener: (context, state){
        if(!(state is AuthenticationUninitialized))
          Navigator.of(context).pushReplacementNamed(Routes.DASHBOARD);
      },
      child: Scaffold(
        body: Container(
            color: Colors.white,
            child: Container(
              child: Stack(
                children: <Widget>[
                  //Dummy container for hero transition
                  Center(
                    child: Hero(
                        tag: 'logoHero',
                        child: Container(
                          width: 200,
                          height: 200,
                        )),
                  ),
                  Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 400, maxHeight: 400),
                      child: Container(
                        child: Text("Hello")/*FlareActor(
                        "assets/anims/logo_intro_bel.flr",
                        alignment: Alignment.center,
                        fit: BoxFit.contain,
                        animation: "intro",
                        callback: (animName) {
                          Navigator.pushReplacementNamed(context, Routes.DASHBOARD);
                        },
                      )*/,
                      ),
                    ),
                  ),
                ],
              ),
            )),
      ),
    );
  }
}

