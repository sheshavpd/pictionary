import '../utils/utils.dart';
import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String _name;
  final String _accessToken;
  final String _uid;
  final String _email;
  final String nick;
  final String avatar;

  const User(this._name, this._uid, this._email, this.nick, this.avatar,
      this._accessToken);

  String get name => _name;

  String get accessToken => _accessToken;

  String get uid => _uid;

  static User fromToken(String token) {
    final tokenJson = getJsonFromJWT(token);
    return User(tokenJson['name'], tokenJson['uid'], tokenJson['email'],
        tokenJson['name'], tokenJson['avatar'], token);
  }

  @override
  // TODO: implement props
  List<Object> get props => [_name, _uid, _email, nick, _accessToken];
}
