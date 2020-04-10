class GameEventConstants {
  static const CHOOSING_STARTED = "CHOOSING_STARTED";
  static const DRAWING_STARTED = "DRAWING_STARTED";
  static const GAME_ENDED = "GAME_ENDED";
  static const GUESS_SUCCESS = "GUESS_SUCCESS";
  static const HINT = "HINT";
  static const GUESS_SIMILAR = "GUESS_SIMILAR";
  static const GUESS_FAIL = "GUESS_FAIL";
  static const DRAWING_COMPLETE = "DRAWING_COMPLETE";
  static const GUESS_SUBMIT = "GUESS_SUBMIT"; //msg type to send to server
  static const WORD_CHOSEN = "WORD_CHOSEN"; //msg type to send to server
  static const USER_LEFT = "USER_LEFT";
  static const USER_JOINED = "USER_JOINED";
  static const STROKE = 101;
  static const CLEAR_BOARD = "CLEAR_BOARD";
}

class GameStateConstants {
  static const CHOOSING = "CHOOSING";
  static const DRAWING = "DRAWING";
  static const ENDED = "ENDED";
}


class PeerConnConstants {
  static const OFFER = "OFFER";
  static const ANSWER = "ANSWER";
  static const CANDIDATE = "CANDIDATE";
}