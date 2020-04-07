import 'package:equatable/equatable.dart';

abstract class ConnectionEvent extends Equatable {
  const ConnectionEvent();
  @override
  List<Object> get props => [];
}

class Connecting extends ConnectionEvent {
  @override
  String toString() => 'Connecting';

}

class Connected extends ConnectionEvent {
  @override
  String toString() => 'Connected';
}

class NotConnected extends ConnectionEvent {
  @override
  String toString() => 'NotConnected';
}

class NotAuthorized extends ConnectionEvent {
  @override
  String toString() => 'NotAuthorized';
}