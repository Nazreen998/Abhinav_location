// lib/services/location_service.dart
import 'package:geolocator/geolocator.dart';

class LocationService {
  static const double allowedRadius = 30.0;

  static Future<Position> getCurrentPosition() async {
    bool service = await Geolocator.isLocationServiceEnabled();
    if (!service) throw "Location service off";

    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied) throw "Permission denied";
    }
    if (perm == LocationPermission.deniedForever) {
      throw "Permission permanently denied";
    }

    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  static double distanceMeters({
    required double sLat,
    required double sLng,
    required double uLat,
    required double uLng,
  }) {
    return Geolocator.distanceBetween(sLat, sLng, uLat, uLng);
  }
}
