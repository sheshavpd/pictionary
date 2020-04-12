import 'dart:async';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pictionary/models/models.dart';
import 'package:pictionary/repositories/data_providers/unilinks_provider.dart';

import './data_providers/game_data_provider.dart';

class GameRepository {
  final User user;
  bool micPermissionsGranted;
  final UniLinkProvider _uniLinkProvider = UniLinkProvider();

  GameRepository(this.user) {
    _ensureMicPermissionInitialized();
  }

  _ensureMicPermissionInitialized() async {
    micPermissionsGranted = await Permission.microphone.isGranted;
  }

  final GameDataProvider gameDataProvider = GameDataProvider();

  Future<Map> createPrivateRoom(bool audioEnabled) async {
    return await gameDataProvider.createPrivateRoom(
        user.accessToken, audioEnabled);
  }

  Future<Map> join(String roomID) async {
    return await gameDataProvider.joinPrivateRoom(
        token: user.accessToken, roomID: roomID);
  }

  Future<Map> joinPub() async {
    return await gameDataProvider.joinPublicRoom(token: user.accessToken);
  }

  Future<bool> tryMicPermission() async {
    //Might not be initialized when app is opened via deeplink. Race condition leads to this function be called before _ensureMicPermissionInitialized() of gameRepository is finished.
    if (micPermissionsGranted == null) await _ensureMicPermissionInitialized();
    if (!micPermissionsGranted) {
      BotToast.showText(
          text:
              "Please provide microphone permission to communicate with other players",
          duration: Duration(seconds: 5),
          align: Alignment(0, -0.9));
      if (await Permission.microphone.request().isGranted) {
        micPermissionsGranted = true;
        return true;
      }
    }
    return false;
  }

  void onExternalRoomIDReceived(Function(String) roomIDReceiver) {
    _uniLinkProvider.onRoomIDReceived(roomIDReceiver);
  }

  void dispose() {
    _uniLinkProvider.dispose();
  }
}
