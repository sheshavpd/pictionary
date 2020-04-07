import 'dart:async';
import 'package:pictionary/models/models.dart';

import './data_providers/game_data_provider.dart';

class GameRepository {
  final User user;
  GameRepository(this.user);
  final GameDataProvider gameDataProvider = GameDataProvider();
  Future<Map> createPrivateRoom() async {
    return await gameDataProvider.createPrivateRoom(user.accessToken);
  }

  Future<Map> join(String roomID) async {
    return await gameDataProvider.joinPrivateRoom(token: user.accessToken, roomID: roomID);
  }
}
