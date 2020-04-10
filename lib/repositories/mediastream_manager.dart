import 'package:flutter_webrtc/get_user_media.dart';
import 'package:flutter_webrtc/media_stream.dart';

class LocalMediaStreamManager {
  MediaStream _localStream;
  bool _isMuted = false;
  static final LocalMediaStreamManager _localMediaStreamManager = LocalMediaStreamManager._internal();

  factory LocalMediaStreamManager() {
    return _localMediaStreamManager;
  }

  LocalMediaStreamManager._internal();

  final Map<String, dynamic> _mediaConstraints = {
    "audio": {
      "autoGainControl": false,
      "channelCount": 1,
      "echoCancellation": true,
      "latency": 0,
      "noiseSuppression": true,
      "sampleRate": 22050,
      "sampleSize": 8,
      "volume": 1.0
    },
    "video":false
  };

  Future<MediaStream> getLocalAudioStream() async{
    if(_localStream == null) {
      _localStream = await navigator.getUserMedia(_mediaConstraints);
      if(_localStream.getAudioTracks() != null && _localStream.getAudioTracks().length > 0)
        _localStream.getAudioTracks()[0].enableSpeakerphone(true);
      muted = _isMuted;
    }
    return _localStream;
  }

  set muted(bool muted) {
    if(_localStream != null && _localStream.getAudioTracks() != null && _localStream.getAudioTracks().length > 0) {
        _localStream.getAudioTracks()[0].setMicrophoneMute(muted);
    }
    _isMuted = muted;
  }

  Future<void> disposeLocalAudioStream() async{
    if(_localStream != null) {
      try {
        await _localStream.dispose();
      }catch(e){print(e);}
    }
    _localStream = null;
  }

}