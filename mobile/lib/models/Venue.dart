class Venue {
  Venue({String? name, double? latitude, double? longitude, int? geofenceRadiusM}) {
    _name = name;
    _latitude = latitude;
    _longitude = longitude;
    _geofenceRadiusM = geofenceRadiusM;
  }

  Venue.fromJson(dynamic json) {
    _name = json['name'];
    _latitude = (json['latitude'] as num?)?.toDouble();
    _longitude = (json['longitude'] as num?)?.toDouble();
    _geofenceRadiusM = (json['geofenceRadiusM'] as num?)?.toInt();
  }

  String? _name;
  double? _latitude;
  double? _longitude;
  int? _geofenceRadiusM;

  String? get name => _name;
  double? get latitude => _latitude;
  double? get longitude => _longitude;
  int? get geofenceRadiusM => _geofenceRadiusM;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['name'] = _name;
    map['latitude'] = _latitude;
    map['longitude'] = _longitude;
    map['geofenceRadiusM'] = _geofenceRadiusM;
    return map;
  }
}
