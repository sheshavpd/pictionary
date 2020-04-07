import 'package:equatable/equatable.dart';
import 'package:pictionary/common/pretty_print.dart';

import 'Player.dart';

class GameDetails extends Equatable {
  final String gameUID;
  final String state;
  final String stateID;
  final int round;
  final int targetTimeMs;
  final int startTimeMs;
  final Player currentArtist;
  final List<Player> players;

  GameDetails(
      {this.gameUID,
      this.state,
      this.stateID,
      this.round,
      this.targetTimeMs = 0,
      this.startTimeMs = 0,
      this.players,
      this.currentArtist});

  static GameDetails fromJSON(Map pJsonMap) {
    List<Player> players;
    Player currentArtist;
    if (pJsonMap.containsKey('players')) {
      players =
          (pJsonMap['players'] as List).map((p) => Player.fromJSON(p)).toList();
      currentArtist = players.firstWhere((p) => p.uid == pJsonMap['artistID'],
          orElse: () => null);
    }
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    return GameDetails(
        gameUID: pJsonMap['gameUID'],
        state: pJsonMap['state'],
        stateID: pJsonMap['stateID'],
        round: pJsonMap['round'],
        startTimeMs: currentTime,
        targetTimeMs: currentTime + (pJsonMap['timeout'] ?? 0),
        currentArtist: currentArtist,
        players: players);
  }

  GameDetails copyWith(
      {String gameUID,
      String state,
      String stateID,
      int round,
      int timeout,
      Player currentArtist,
      List<Player> players}) {
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    return GameDetails(
        gameUID: gameUID ?? this.gameUID,
        state: state ?? this.state,
        stateID: stateID ?? this.stateID,
        round: round ?? this.round,
        startTimeMs: timeout != null ? currentTime : this.startTimeMs,
        targetTimeMs:
            timeout != null ? currentTime + timeout : this.targetTimeMs,
        currentArtist: currentArtist ?? this.currentArtist,
        players: players ?? this.players);
  }

  GameDetails copyWithGD(GameDetails oGameDetails) {
    return GameDetails(
        gameUID: oGameDetails.gameUID ?? this.gameUID,
        state: oGameDetails.state ?? this.state,
        stateID: oGameDetails.stateID ?? this.stateID,
        round: oGameDetails.round ?? this.round,
        startTimeMs: oGameDetails.startTimeMs ?? this.startTimeMs,
        targetTimeMs: oGameDetails.targetTimeMs ?? this.targetTimeMs,
        currentArtist: oGameDetails.currentArtist ?? this.currentArtist,
        players: oGameDetails.players ?? this.players);
  }

  @override
  // TODO: implement props
  List<Object> get props => [
        this.gameUID,
        this.state,
        this.stateID,
        this.round,
        this.targetTimeMs,
        this.currentArtist,
        this.players
      ];

  @override
  String toString() {
    return prettyPrint({
      'gameUID': this.gameUID,
      'state': this.state,
      'stateID': this.stateID,
      'round': this.round,
      'timeout': (targetTimeMs - startTimeMs),
      'currentArtist': this.currentArtist.toString(),
      'players': players?.toString() ?? 'N/A',
    });
  }
}
