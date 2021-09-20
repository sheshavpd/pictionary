import 'package:flutter/material.dart';
import 'package:pictionary/models/stroke.dart';
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
import 'package:pictionary/repositories/webrtc_conn_manager.dart';


abstract class AudioEvent extends Equatable {
  const AudioEvent();
  @override
  List<Object> get props => [];
}

class AudioSetInGameAudioEnabled extends AudioEvent {
  final bool enabled;
  AudioSetInGameAudioEnabled(this.enabled);
  @override
  String toString() => 'AudioSetInGameAudioEnabled';
  @override
  List<Object> get props => [enabled];
}

class AudioSetMicrophone extends AudioEvent {
  final bool enabled;
  AudioSetMicrophone(this.enabled);
  @override
  String toString() => 'AudioSetMicrophone';
  @override
  List<Object> get props => [enabled];
}


class AudioSetSpeaker extends AudioEvent {
  final bool enabled;
  AudioSetSpeaker(this.enabled);
  @override
  String toString() => 'AudioSetSpeaker';
  @override
  List<Object> get props => [enabled];
}

class AudioRestartUserVoiceComm extends AudioEvent {
  final String userID;
  AudioRestartUserVoiceComm(this.userID);
  @override
  String toString() => 'AudioRestartUserVoiceComm';
  @override
  List<Object> get props => [userID];
}

class AudioUserConStatusChanged extends AudioEvent {
  final RTCIceStateMsg stateMsg;
  AudioUserConStatusChanged(this.stateMsg);
  @override
  String toString() => 'AudioUserConStatusChanged';
  @override
  List<Object> get props => [stateMsg];
}
