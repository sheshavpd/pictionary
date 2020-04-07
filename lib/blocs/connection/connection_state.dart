import 'package:equatable/equatable.dart';

abstract class AppConnectionState extends Equatable {
  String presentableString(); //Useful to display the status in the user interface.

  @override
  // TODO: implement props
  List<Object> get props => [];
}

class ConnectionConnecting extends AppConnectionState {
  @override
  String toString() => 'ConnectionConnecting';

  @override
  String presentableString() {
    return "Connecting";
  }


}

class ConnectionConnected extends AppConnectionState {
  @override
  String toString() => 'ConnectionConnected';

  @override
  String presentableString() {
    return "Connected";
  }
}

class ConnectionNotConnected extends AppConnectionState {
  @override
  String toString() => 'ConnectionNotConnected';

  @override
  String presentableString() {
    return "Disconnected";
  }
}

class ConnectionNotAuthorized extends AppConnectionState {
  @override
  String toString() => 'ConnectionNotAuthorized';

  @override
  String presentableString() {
    return "Not Authorized";
  }
}