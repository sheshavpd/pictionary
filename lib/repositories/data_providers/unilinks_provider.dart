import 'dart:async';
import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:pictionary/common/app_logger.dart';
import 'package:pictionary/common/pretty_print.dart';
import 'package:uni_links/uni_links.dart';

// ...
class UniLinkProvider {
  StreamSubscription _sub;
  String _latestRoomID;
  UniLinkProvider() {
    initUniLinks();
  }

  Future<Null> initUniLinks() async {
    //Capture app initiating link.
    try {
      this._onURIReceived(await getInitialUri());
    } catch(e) {
      alog.e(e);
      BotToast.showText(
          text:
          "Oops. Something went wrong while fetching game room id. Please copy the room code and paste it manually",
          duration: Duration(seconds: 5));
    }

    // Attach a listener to the stream
    _sub = getUriLinksStream().listen(this._onURIReceived, onError: (err) {
      alog.e(err);
      BotToast.showText(
          text:
          "Oops. Something went wrong while fetching game room id. Please copy the room code and paste it manually",
          duration: Duration(seconds: 5));
    });
  }

  void _onURIReceived(Uri uri) {
    alog.d("Captured link ${uri.toString()}");
    if(uri == null) {
      return;
    }
    alog.d(prettyPrint(uri.queryParameters));
    if(uri.queryParameters.containsKey('id')) {
      if(this.roomIDReceiver == null) {
        _latestRoomID = uri.queryParameters['id'];
      } else {
        this.roomIDReceiver?.call(uri.queryParameters['id']);
        _latestRoomID = null;
      }
    }
  }

  void Function(String) roomIDReceiver;
  void onRoomIDReceived(Function(String) roomIDReceiver) {
    this.roomIDReceiver = roomIDReceiver;
    if(_latestRoomID != null) {
      this.roomIDReceiver.call(_latestRoomID);
      _latestRoomID = null;
    }
  }

  void dispose() {
    _sub.cancel();
  }

}
