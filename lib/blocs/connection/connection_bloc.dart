import 'dart:async';

import '../../blocs/authentication/authentication.dart';
import '../../repositories/AppSocket.dart';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import '../../AppConstants.dart';
import 'connection.dart';

class ConnectionBloc extends Bloc<ConnectionEvent, AppConnectionState> {
  final _socket = AppSocket();
  final AuthenticationBloc _authenticationBloc;
  StreamSubscription<AuthenticationState> authenticationSubscription;
  StreamSubscription<SocketConStatus> socketStatusSubscription;

  ConnectionBloc(this._authenticationBloc) {
    _onAuthenticationStateChange(_authenticationBloc.state); //Check and connect to socket initially.
    authenticationSubscription = _authenticationBloc.listen(_onAuthenticationStateChange);
    socketStatusSubscription = _socket.status.listen((status) {
      switch (status) {
        case SocketConStatus.Connecting:
          add(Connecting());
          break;
        case SocketConStatus.Connected:
          add(Connected());
          break;
        case SocketConStatus.NotConnected:
          add(NotConnected());
          break;
        case SocketConStatus.NotAuthorized:
          add(NotAuthorized());
          break;
      }

      /*if(status == SocketConStatus.Connected)
        _userTracker.startTracking();
      else _userTracker.stopTracking();*/

    });
  }

  void _onAuthenticationStateChange(AuthenticationState state) {
    //Start Socket connect-retry loop once authenticated.
    if (state is AuthenticationAuthenticated) {
      _socket.connect("$WS_BASE_URL/socket/" + state.user.accessToken);
      return;
    }
    _socket.disconnect(); //Disconnect otherwise.
  }

  @override
  AppConnectionState get initialState => ConnectionConnecting();

  @override
  Stream<AppConnectionState> mapEventToState(
    ConnectionEvent event,
  ) async* {
    if (event is Connecting) {
      yield ConnectionConnecting();
    }

    if (event is Connected) {
      yield ConnectionConnected();
    }

    if (event is NotConnected) {
      yield ConnectionNotConnected();
    }

    if (event is NotAuthorized) {
      yield ConnectionNotAuthorized();
      _authenticationBloc.add(LoggedOut());
    }
  }

  @override
  Future<void> close() {
    // TODO: implement dispose
    authenticationSubscription.cancel();
    socketStatusSubscription.cancel();
    return super.close();
  }
}
