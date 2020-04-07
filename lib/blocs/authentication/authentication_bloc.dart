import 'dart:async';

import '../../models/User.dart';
import '../../repositories/user_repository.dart';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'authentication.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final UserRepository userRepository;

  AuthenticationBloc({@required this.userRepository})
      : assert(userRepository != null);

  @override
  AuthenticationState get initialState => AuthenticationUninitialized();

  String get userToken => state is AuthenticationAuthenticated? (state as AuthenticationAuthenticated).user.accessToken: '';

  @override
  Stream<AuthenticationState> mapEventToState(
    AuthenticationEvent event,
  ) async* {
    if (event is AppStarted) {
      final User existingUser = await userRepository.getUser();

      //await Future.delayed(Duration(milliseconds: 2000));
      if (existingUser != null) {
        yield AuthenticationAuthenticated(existingUser);
      } else {
        yield AuthenticationUnauthenticated();
      }
    }

    if (event is LoggedIn) {
      yield AuthenticationLoading();
      await userRepository.persistUser(event.user);
      yield AuthenticationAuthenticated(event.user);
    }

    if (event is LoggedOut) {
      yield AuthenticationLoading();
      await userRepository.signOutGoogle();
      await userRepository.deleteUser();
      yield AuthenticationUnauthenticated();
    }
  }
}
