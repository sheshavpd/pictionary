import 'dart:async';
import 'dart:io';

import 'package:rxdart/rxdart.dart';

enum SocketConStatus { Connecting, Connected, NotConnected, NotAuthorized }

class AppSocket {
  static final AppSocket _appSocket = AppSocket._internal();

  factory AppSocket() {
    return _appSocket;
  }

  AppSocket._internal();

  WebSocket _webSocket;
  SocketConStatus _webSocketStatus = SocketConStatus.NotConnected;
  bool _isRetrying = false;
  String _url;
  final _statusSubject =
  BehaviorSubject<SocketConStatus>.seeded(SocketConStatus.NotConnected);

  void connect(String url) async {
    this._url = url;
    //If not already retrying, set the flag.
    if (!_isRetrying) {
      _isRetrying = true;
      _tryConnecting();
    }
  }

  void disconnect() {
    if (_webSocketStatus == SocketConStatus.Connected) _webSocket.close();
    {
      _isRetrying = false;
      _retryTimer?.cancel();
    }
  }

  void _tryConnecting() async {
    if (_webSocketStatus == SocketConStatus.Connecting || !_isRetrying) return;
    _setWebSocketStatus(SocketConStatus.Connecting);
    print("Trying socket connect");
    try {
      _webSocket = await WebSocket.connect(this._url);

      _webSocket.listen(onData, onError: (e) {
        print("Websocket error: " + e.toString());
      }, onDone: _onSocketClose);

      _setWebSocketStatus(SocketConStatus.Connected);
      _keepAlive();
    } catch (e) {
      //Websocket closed due to upgrade issues, which will be due to authentication error.
      if (e.toString().contains("upgraded")) {
        _setWebSocketStatus(SocketConStatus.NotAuthorized);
        disconnect();
      } else {
        _setWebSocketStatus(SocketConStatus.NotConnected);
        _retry();
      }
      print(e);
    }
  }

  Timer _keepAliveTimer, _retryTimer;

  void _keepAlive() {
    _keepAliveTimer =
        Timer.periodic(const Duration(milliseconds: 20000), (timer) {
          if (isSocketOpen()) {
            _webSocket.add("ping");
          }
        });
  }

  void _cancelKeepAlive() {
    if (_keepAliveTimer != null && _keepAliveTimer.isActive)
      _keepAliveTimer.cancel();
  }

  void _onSocketClose() {
    _cancelKeepAlive();
    _setWebSocketStatus(SocketConStatus.NotConnected);
    _retry();
  }

  void _retry() {
    if (_isRetrying) {
      _retryTimer = Timer(const Duration(milliseconds: 3000), _tryConnecting);
    }
  }

  Stream<SocketConStatus> get status => _statusSubject.stream;

  void onData(dynamic message) {
    print("New data received: " + message);
  }

  bool isSocketOpen() {
    return _webSocketStatus == SocketConStatus.Connected &&
        _webSocket.readyState == WebSocket.open;
  }

  bool sendMessage(dynamic message) {
    try {
      if (isSocketOpen()) _webSocket.add(message);
      return true;
    } catch (e) {
      return false;
    }
  }

  void _setWebSocketStatus(SocketConStatus value) {
    if (_webSocketStatus != value) {
      _webSocketStatus = value;
      if (!_statusSubject.isClosed) _statusSubject.add(value);
    }
  }

  void dispose() {
    _statusSubject.close();
  }
}
