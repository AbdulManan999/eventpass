import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

/// Thrown when the phone can't produce a location. [code] is mapped to a
/// translated message by the screen.
class LocationException implements Exception {
  LocationException(this.code);

  /// location_disabled, location_denied or location_denied_forever.
  final String code;

  @override
  String toString() => code;
}

/// A position fix, reduced to what self check-in sends.
class LocationFix {
  LocationFix({required this.latitude, required this.longitude, required this.accuracyM, required this.isMocked});

  final double latitude;
  final double longitude;
  final double accuracyM;
  final bool isMocked;
}

/// Overridable in tests.
final locationServiceProvider = Provider<LocationService>((ref) => LocationService());

class LocationService {
  /// Asks for permission if needed, then takes one high-accuracy fix.
  Future<LocationFix> currentFix() async {
    if (!await Geolocator.isLocationServiceEnabled()) throw LocationException('location_disabled');

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) throw LocationException('location_denied');
    if (permission == LocationPermission.deniedForever) throw LocationException('location_denied_forever');

    final p = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.best, timeLimit: Duration(seconds: 20)),
    );
    return LocationFix(latitude: p.latitude, longitude: p.longitude, accuracyM: p.accuracy, isMocked: p.isMocked);
  }

  Future<void> openSettings() => Geolocator.openAppSettings();
}
