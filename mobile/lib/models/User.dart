/// Logged-in user, persisted in SharedPreferences via Utils.setUserData.
class User {
  User({String? id, String? name, String? email, String? role}) {
    _id = id;
    _name = name;
    _email = email;
    _role = role;
  }

  User.fromJson(dynamic json) {
    _id = json['id']?.toString();
    _name = json['name'];
    _email = json['email'];
    _role = json['role'];
  }

  String? _id;
  String? _name;
  String? _email;
  String? _role;

  String? get id => _id;
  String? get name => _name;
  String? get email => _email;

  /// `attendee` or `organizer`.
  String? get role => _role;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['name'] = _name;
    map['email'] = _email;
    map['role'] = _role;
    return map;
  }
}
