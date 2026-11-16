import 'dart:math';

const double _earthRadiusM = 6371008.8;

double _rad(double deg) => deg * pi / 180;

/// Great-circle distance in metres (haversine). Same formula as the backend.
double distanceMeters(double lat1, double lon1, double lat2, double lon2) {
  final dLat = _rad(lat2 - lat1);
  final dLon = _rad(lon2 - lon1);
  final a = pow(sin(dLat / 2), 2) + cos(_rad(lat1)) * cos(_rad(lat2)) * pow(sin(dLon / 2), 2);
  return 2 * _earthRadiusM * asin(min(1.0, sqrt(a)));
}

/// "180 m" or "1.5 km".
String formatDistance(num meters) => meters >= 1000 ? '${(meters / 1000).toStringAsFixed(1)} km' : '${meters.round()} m';
