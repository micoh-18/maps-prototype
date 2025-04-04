import 'package:google_maps_flutter/google_maps_flutter.dart';

class Terminal {
  final String id;
  final LatLng location;
  final String? address;
  Terminal({required this.id, required this.location, this.address});

  String get displayName => id;
}

final List<Terminal> marikinaTerminals = [
  Terminal(
      id: "Marikina Public Market Terminal",
      location: LatLng(14.6369, 121.1070)),
  Terminal(id: "SSS Village Terminal", location: LatLng(14.6468, 121.1158)),
  Terminal(id: "Parang Terminal", location: LatLng(14.6212, 121.1009)),
  Terminal(id: "Concepcion Uno Terminal", location: LatLng(14.6437, 121.1345)),
  Terminal(id: "Nangka Terminal", location: LatLng(14.6601, 121.1218)),
  Terminal(id: "Kalumpang Terminal", location: LatLng(14.6543, 121.0967)),
  Terminal(id: "Jesus Dela Peña Terminal", location: LatLng(14.6292, 121.1162)),
  Terminal(id: "Fortune Terminal", location: LatLng(14.6599, 121.1030)),
  Terminal(id: "Malanday Terminal", location: LatLng(14.6732, 121.1165)),
  Terminal(id: "SSS Phase 4 Terminal", location: LatLng(14.6496, 121.1212)),
  Terminal(id: "Riverbanks Terminal", location: LatLng(14.6335, 121.0954)),
];
