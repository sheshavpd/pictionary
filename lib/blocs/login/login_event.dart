import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object> get props => null;
}

class LoginToGoogle extends LoginEvent {
  const LoginToGoogle();
  @override
  String toString() =>
      'LoginTryGoogle';
}

class LoggedInToGoogle extends LoginEvent {
  final String googleToken;

  LoggedInToGoogle({
    @required this.googleToken
  });

  @override
  String toString() =>
      'SignedInToGoogle { token: $googleToken }';

  @override
  // TODO: implement props
  List<Object> get props => [googleToken];
}

