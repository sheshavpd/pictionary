import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';

import 'package:bloc/bloc.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:pictionary/models/models.dart';
import 'package:pictionary/repositories/mediastream_manager.dart';

import 'AppConstants.dart';
import 'blocs/authentication/authentication.dart';
import 'blocs/connection/connection.dart';
import 'common/app_logger.dart';
import 'repositories/user_repository.dart';
import 'repositories/webrtc_conn_manager.dart';
import 'screens/home/home.dart';
import 'screens/screens.dart';
import 'widgets/loading_indicator.dart';

class SimpleBlocDelegate extends BlocDelegate {
  @override
  void onEvent(Bloc bloc, Object event) {
    super.onEvent(bloc, event);
    print(event);
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    alog.d(transition);
  }

  @override
  void onError(Bloc bloc, Object error, StackTrace stacktrace) {
    super.onError(bloc, error, stacktrace);
    alog.e(error);
  }
}



void main() {
  BlocSupervisor.delegate = SimpleBlocDelegate();
  runApp(AppRoot());
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp
  ]);
  SystemChrome.setEnabledSystemUIOverlays ([SystemUiOverlay.bottom]);
}

class NoAnimPageRoute<T> extends MaterialPageRoute<T> {
  NoAnimPageRoute({@required WidgetBuilder builder}) : super(builder: builder);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    // TODO: implement buildTransitions
    return child;
  }
}

class AppRoot extends StatelessWidget {
  final userRepository;
  final authBloc;
  AppRoot._({@required this.userRepository, @required this.authBloc});
  factory AppRoot() {
    final rep = UserRepository();
    final authBloc = AuthenticationBloc(userRepository: rep)..add(AppStarted());
    return AppRoot._(userRepository: rep,authBloc: authBloc);
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthenticationBloc>(
      create: (context) {
        return authBloc;
      },
      child: RepositoryProvider<UserRepository>(
        create: (BuildContext context) {
          return userRepository;
        },
        child: BotToastInit(
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Pictionary',
            navigatorObservers: [BotToastNavigatorObserver()],
            theme: ThemeData(
              fontFamily: 'CatCafe',
              primarySwatch: Colors.deepPurple,
            ),
            initialRoute: Routes.DASHBOARD,
            routes: {
              /*case Routes.LOGIN:
                return NoAnimPageRoute(builder: (_) => const SplashScreen());
                break;*/
              Routes.DASHBOARD: (_) => App()
            },
            /*routes: {
              Routes.SPLASH: (context) => SplashScreen(),
              Routes.DASHBOARD: MaterialPageRoute(builder: (_) => App()),
            }*/
          ),
        )
      ),
    );
  }
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
      builder: (context, state) {
        if (state is AuthenticationAuthenticated) {
          return BlocProvider<ConnectionBloc>(
            lazy: false,
            create: (BuildContext context) {
              return ConnectionBloc(
                  BlocProvider.of<AuthenticationBloc>(context));
            },
            child: HomeScreen(),
          );
        }
        if (state is AuthenticationUnauthenticated) {
          return LoginPage();
        }
        if (state is AuthenticationLoading) {
          return LoadingIndicator();
        }
        return LoginPage();
      },
    );
  }
}


