import 'dart:async';

import '../../blocs/authentication/authentication.dart';
import '../../repositories/user_repository.dart';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';

import 'login.dart';

import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final UserRepository userRepository;
  final AuthenticationBloc authenticationBloc;

  LoginBloc({
    @required this.userRepository,
    @required this.authenticationBloc,
  })
      : assert(userRepository != null),
        assert(authenticationBloc != null);

  @override
  LoginState get initialState => LoginInitial();

  @override
  Stream<LoginState> mapEventToState(LoginEvent event) async* {
    if (event is LoggedInToGoogle) {
      yield LoginLoading();
      try {
        final user =
        await userRepository.authenticate(token: event.googleToken);
        authenticationBloc.add(LoggedIn(user: user));
        yield LoginInitial();
      } catch (error) {
        yield LoginFailure(error: error.toString());
      }
    } else if (event is LoginToGoogle) {
      yield LoginLoading();
      try {
        final token = await userRepository.signInWithGoogle();
        if (token != null)
          add(LoggedInToGoogle(googleToken: token));
        else yield LoginInitial();
      } catch (error) {
        yield LoginFailure(error: error.toString());
      }
    }
  }
}
