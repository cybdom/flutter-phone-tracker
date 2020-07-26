import 'dart:convert';

import 'package:phone_tracker/global.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

enum LoginStatus { error, loading, idle, loggedIn }

class AuthService with ChangeNotifier {
  dynamic _error = "";
  LoginStatus _status = LoginStatus.idle;
  String _token;

  String get token => _token;

  dynamic get error => _error;

  LoginStatus get status => _status;

  retry() {
    _error = "";
    _status = LoginStatus.idle;
    _token = "";
    notifyListeners();
  }

  Future<bool> login({username, password}) async {
    _status = LoginStatus.loading;
    notifyListeners();
    final response = await http.post(
      "$baseServerUrl/login",
      body: jsonEncode({
        'username': '$username',
        'password': '$password',
      }),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    if (response.statusCode == 200) {
      final token = jsonDecode(response.body)['accessToken'];
      await saveToken(token);
      return true;
    } else {
      _status = LoginStatus.error;
      _error = jsonDecode(response.body);
      notifyListeners();
      return false;
    }
  }

  Future saveToken(token) async {
    final _storage = FlutterSecureStorage();
    await _storage.write(key: "token", value: token);
    _status = LoginStatus.loggedIn;
    _token = token;
    notifyListeners();
    return;
  }

  Future getSavedToken() async {
    final _storage = FlutterSecureStorage();
    _token = await _storage.read(key: "token");
    if (_token != null) {
      _status = LoginStatus.loggedIn;
      notifyListeners();
    } else {
      _status = LoginStatus.idle;
      notifyListeners();
    }
  }

  logout() async {
    final _storage = FlutterSecureStorage();
    await _storage.delete(key: "token");
    _status = LoginStatus.idle;
    notifyListeners();
  }
}
