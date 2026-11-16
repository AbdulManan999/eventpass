class RegisterRequest {
  RegisterRequest({String? name, String? email, String? password}) {
    _name = name;
    _email = email;
    _password = password;
  }

  String? _name;
  String? _email;
  String? _password;

  String? get name => _name;
  String? get email => _email;
  String? get password => _password;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['name'] = _name;
    map['email'] = _email;
    map['password'] = _password;
    map['role'] = 'attendee';
    return map;
  }
}
