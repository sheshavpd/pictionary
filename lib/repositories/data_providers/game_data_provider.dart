import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../common/failed_request_exception.dart';
import '../../AppConstants.dart';

class GameDataProvider {
  const GameDataProvider();
  Future<Map> createPrivateRoom(String token, bool audioEnabled) async {
    try {
      final response = await http.post('$BASE_URL/game/create', body: {'audio': audioEnabled.toString()}, headers: {'token':token, 'app_version': APP_VERSION});
      if (response.statusCode == HttpStatus.ok) {
        return json.decode(response.body)['newRoomDetails'];
      } else {
        final respJson = json.decode(response.body);
        throw FailedRequestException(respJson['message'] ??
            'Something went wrong. Please try again later.');
      }
    } catch (e) {
      print(e);
      if(e is FailedRequestException)
        throw e;
      else throw Exception("Network error. Please ensure you're connected to the network.");
    }
  }

  Future<Map> joinPrivateRoom({@required String token, @required String roomID}) async {
    try {

      final response = await http.post('$BASE_URL/game/join', body: {
        'roomID': roomID
      }, headers: {'token':token, 'app_version': APP_VERSION});
      if (response.statusCode == HttpStatus.ok) {
        return json.decode(response.body)['gameDetails'];
      } else {
        final respJson = json.decode(response.body);
        throw FailedRequestException(respJson['message'] ??
            'Something went wrong. Please try again later.');
      }
    } catch (e) {
      print(e);
      if(e is FailedRequestException)
        throw e;
      else throw Exception("Network error. Please ensure you're connected to the network.");
    }
  }

  Future<Map> joinPublicRoom({@required String token}) async {
    try {

      final response = await http.post('$BASE_URL/game/join-pub', headers: {'token':token, 'app_version': APP_VERSION});
      if (response.statusCode == HttpStatus.ok) {
        return json.decode(response.body)['gameDetails'];
      } else {
        final respJson = json.decode(response.body);
        throw FailedRequestException(respJson['message'] ??
            'Something went wrong. Please try again later.');
      }
    } catch (e) {
      print(e);
      if(e is FailedRequestException)
        throw e;
      else throw Exception("Network error. Please ensure you're connected to the network.");
    }
  }
}