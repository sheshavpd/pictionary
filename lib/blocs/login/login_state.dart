import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

abstract class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object> get props => null;
}

class LoginInitial extends LoginState {
  @override
  String toString() => 'LoginInitial';

}

class LoginLoading extends LoginState {
  @override
  String toString() => 'LoginLoading';
}

class LoginFailure extends LoginState {
  final String error;

  LoginFailure({@required this.error});

  @override
  String toString() => 'LoginFailure { error: $error }';

  @override
  List<Object> get props => [error];
}

