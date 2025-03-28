import 'package:google_maps_flutter/google_maps_flutter.dart';

class Terminal {
  final String id;
  final LatLng location;
  final String? address;
  Terminal({required this.id, required this.location, this.address});

  String get displayName => id;
}

final List<Terminal> allMyTerminals = [
  Terminal(id: "QC Circle Stop", location: LatLng(14.6507, 121.0488)),
  Terminal(id: "SM North", location: LatLng(14.6569, 121.0325)),
  Terminal(id: "Trinoma", location: LatLng(14.652, 121.034)),
  Terminal(
      id: "Araneta Center Cubao",
      location: LatLng(14.6208, 121.0544)), // Further away
];
