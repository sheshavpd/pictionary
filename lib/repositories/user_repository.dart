import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';

import '../common/failed_request_exception.dart';
import '../models/models.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'package:device_info/device_info.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../AppConstants.dart';

class UserRepository {

  String _userToken='';
  Future<User> authenticate(
      {@required final String token}) async {
    try {
      DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
      String deviceOS, deviceId, deviceName;
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidDeviceInfo =
            await deviceInfoPlugin.androidInfo;
        deviceOS = "android " + androidDeviceInfo.version.sdkInt.toString();
        deviceName = androidDeviceInfo.model;
        deviceId = androidDeviceInfo.androidId;
      } else if (Platform.isIOS) {
        IosDeviceInfo iosDeviceInfo = await deviceInfoPlugin.iosInfo;
        deviceOS = "ios " +
            iosDeviceInfo.systemName +
            ", " +
            iosDeviceInfo.systemVersion;
        deviceName = iosDeviceInfo.utsname.machine;
        deviceId = iosDeviceInfo.identifierForVendor;
      } else
        throw FailedRequestException("Unsupported Device");

      final response = await http.post('$BASE_URL/auth/google', body: {
        "token":  token,
        "device_info": json.encode({"app_version": APP_VERSION,
          "device_OS": deviceOS,
          "device_id": deviceId,
          "device_name": deviceName})
      });
      if (response.statusCode == HttpStatus.ok) {
        final respJson = json.decode(response.body);
        return User.fromToken(respJson['accessToken']);
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

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  Future<String> signInWithGoogle() async {
    GoogleSignInAccount googleSignInAccount;
    try {
      googleSignInAccount =  await googleSignIn.signIn();
    } catch(e){
      throw Exception("Network error. Please check your connection.");
    }
    if(googleSignInAccount == null)
      return null;
    final GoogleSignInAuthentication googleSignInAuthentication =
    await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    final AuthResult authResult = await _auth.signInWithCredential(credential);
    final FirebaseUser user = authResult.user;

    try {
      assert(!user.isAnonymous);
      assert(await user.getIdToken() != null);
      assert(user.email != null);
      assert(user.displayName != null);
      assert(user.photoUrl != null);
    }catch(e){
      throw Exception("Sign in error. Please try with a different account");
    }

    final FirebaseUser currentUser = await _auth.currentUser();
    return (await currentUser.getIdToken()).token;
/*// Only taking the first part of the name, i.e., First Name
  if (name.contains(" ")) {
    name = name.substring(0, name.indexOf(" "));
  }*/
  }

  Future<void> signOutGoogle() async{
    await googleSignIn.signOut();
  }

  Future<void> deleteUser() async {
    (await SharedPreferences.getInstance()).remove("ustok");
  }

  Future<void> persistUser(User user) async {
    (await SharedPreferences.getInstance()).setString("ustok", user.accessToken);
  }

  Future<bool> hasUser() async{
    return (await SharedPreferences.getInstance()).containsKey("ustok");
  }

  Future<User> getUser() async {
    String token = (await SharedPreferences.getInstance()).getString("ustok");
    return token == null? null: User.fromToken(token);
  }

}
