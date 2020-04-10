import 'dart:async';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pictionary/models/models.dart';

import './data_providers/game_data_provider.dart';

class GameRepository {
  final User user;
  bool micPermissionsGranted;
  GameRepository(this.user) {
    _init();
  }
  _init() async {
    micPermissionsGranted = await Permission.microphone.isGranted;
  }
  final GameDataProvider gameDataProvider = GameDataProvider();
  Future<Map> createPrivateRoom() async {
    return await gameDataProvider.createPrivateRoom(user.accessToken);
  }

  Future<Map> join(String roomID) async {
    return await gameDataProvider.joinPrivateRoom(token: user.accessToken, roomID: roomID);
  }

  Future<bool> tryMicPermission() async {
    if (!micPermissionsGranted) {
        BotToast.showText(text: "Please provider microphone permission to communicate with other players", duration: Duration(seconds: 5), align: Alignment(0, -0.9));
        if(await Permission.microphone.request().isGranted) {
          micPermissionsGranted = true;
          return true;
        }
    }
    return false;
  }
}
