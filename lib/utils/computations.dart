import 'dart:math';
import 'package:google_maps_flutter/google_maps_flutter.dart';

double _degreesToRadians(double degrees) {
  return degrees * pi / 180;
}

double calculateDistance(LatLng latLng1, LatLng latLng2) {
  const double earthRadiusKm = 6371.0;

  final double dLat = _degreesToRadians(latLng2.latitude - latLng1.latitude);
  final double dLon = _degreesToRadians(latLng2.longitude - latLng1.longitude);

  final double lat1Rad = _degreesToRadians(latLng1.latitude);
  final double lat2Rad = _degreesToRadians(latLng2.latitude);

  final double a = sin(dLat / 2) * sin(dLat / 2) +
      cos(lat1Rad) * cos(lat2Rad) * sin(dLon / 2) * sin(dLon / 2);
  final double c = 2 * atan2(sqrt(a), sqrt(1 - a));

  return earthRadiusKm * c;
}
