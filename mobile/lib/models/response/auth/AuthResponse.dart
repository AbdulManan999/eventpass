import 'package:eventpass/models/User.dart';

/// Returned by both `auth/login` and `auth/register`.
class AuthResponse {
  AuthResponse({String? token, User? user}) {
    _token = token;
    _user = user;
  }

  AuthResponse.fromJson(dynamic json) {
    _token = json['token'];
    _user = json['user'] != null ? User.fromJson(json['user']) : null;
  }

  String? _token;
  User? _user;

  String? get token => _token;
  User? get user => _user;
}
