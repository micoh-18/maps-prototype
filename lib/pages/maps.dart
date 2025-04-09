import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:map_prototype/components/dialogs.dart';
import 'package:map_prototype/components/placed_autocomplete.dart';

import 'package:map_prototype/constants/terminals.dart';
import 'package:map_prototype/utils/computations.dart';

class MapSample extends StatefulWidget {
  const MapSample(
      {super.key,
      required this.latitude,
      required this.longitude,
      required this.destination});

  final String destination;
  final double latitude;
  final double longitude;

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  late GoogleMapController mapController;

  //default camera position of Marikina
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(14.650445836519411, 121.10234552274542),
    zoom: 13,
  );

  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  final TextEditingController _fromController = TextEditingController();
  final Set<Marker> _markers = {};
  LatLng? _pointA;
  late LatLng _pointB;
  late LatLng _pointC;
  final Set<Polyline> _polylines = {};
  final TextEditingController _toController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _pointC = LatLng(widget.latitude, widget.longitude);
    _toController.text = widget.destination;
    _markers.add(Marker(
        markerId: MarkerId('_pointC'),
        position: _pointC,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed)));
  }

  Future<void> _addCurvedConnectorLine() async {
    mapController = await _controller.future;

    List<LatLng> curvedPoints = _createCurvedPoints(_pointA!, _pointB);
    List<LatLng> curvedPoints2 = _createCurvedPoints(_pointB, _pointC);
    List<LatLng> curvedPoints3 = _createCurvedPoints(_pointA!, _pointC);

    setState(() {
      _polylines.add(
        Polyline(
          polylineId: PolylineId('curvedConnector'),
          points: curvedPoints,
          color: Colors.blue,
          width: 5,
        ),
      );
      _polylines.add(
        Polyline(
          polylineId: PolylineId('curvedConnector2'),
          points: curvedPoints2,
          color: Colors.green,
          width: 5,
        ),
      );
    });

    LatLngBounds bounds = _boundsFromLatLngList(curvedPoints3);
    mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
  }

  List<LatLng> _createCurvedPoints(LatLng start, LatLng end,
      {int numPoints = 20}) {
    List<LatLng> points = [];
    points.add(start);

    LatLng controlPoint = LatLng(
      (start.latitude + end.latitude) / 2,
      (start.longitude + end.longitude) / 2 + 0.01,
    );

    for (int i = 1; i < numPoints; i++) {
      double t = i / numPoints;
      double lat = (1 - t) * (1 - t) * start.latitude +
          2 * (1 - t) * t * controlPoint.latitude +
          t * t * end.latitude;
      double lng = (1 - t) * (1 - t) * start.longitude +
          2 * (1 - t) * t * controlPoint.longitude +
          t * t * end.longitude;
      points.add(LatLng(lat, lng));
    }
    points.add(end);
    return points;
  }

  LatLngBounds _boundsFromLatLngList(List<LatLng> list) {
    double? x0, x1, y0, y1;
    for (LatLng latLng in list) {
      if (x0 == null) {
        x0 = x1 = latLng.latitude;
        y0 = y1 = latLng.longitude;
      } else {
        if (latLng.latitude > x1!) x1 = latLng.latitude;
        if (latLng.latitude < x0) x0 = latLng.latitude;
        if (latLng.longitude > y1!) y1 = latLng.longitude;
        if (latLng.longitude < y0!) y0 = latLng.longitude;
      }
    }
    return LatLngBounds(
        northeast: LatLng(x1!, y1!), southwest: LatLng(x0!, y0!));
  }

  void _handleToDetail(Prediction prediction) {
    if (prediction.lat != null && prediction.lng != null) {
      setState(() {
        _pointB = LatLng(
            double.parse(prediction.lat!), double.parse(prediction.lng!));
        _markers.add(Marker(
            markerId: MarkerId('pointB'),
            position: _pointB,
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueBlue)));
      });
    }
  }

  void _handleFromDetail(Prediction prediction) {
    if (prediction.lat != null && prediction.lng != null) {
      setState(() {
        _pointA = LatLng(
            double.parse(prediction.lat!), double.parse(prediction.lng!));
        _markers.add(Marker(
            markerId: MarkerId('_pointA'),
            position: _pointA!,
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueBlue)));
      });
    }
  }

  void _handleToClick(Prediction prediction) {
    _toController.text = prediction.description ?? "";
    _toController.selection = TextSelection.fromPosition(
      TextPosition(offset: prediction.description?.length ?? 0),
    );
    setState(() {
      _pointB = LatLng(double.parse(prediction.lat ?? "0.0"),
          double.parse(prediction.lng ?? "0.0"));
      _markers.add(Marker(
          markerId: MarkerId('_pointB'),
          position: _pointB,
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed)));
    });
  }

  void _handleFromClick(Prediction prediction) {
    _fromController.text = prediction.description ?? "";
    _fromController.selection = TextSelection.fromPosition(
      TextPosition(offset: prediction.description?.length ?? 0),
    );
    setState(() {
      _pointA = LatLng(double.parse(prediction.lat ?? "0.0"),
          double.parse(prediction.lng ?? "0.0"));
      _markers.add(Marker(
          markerId: MarkerId('pointA'),
          position: _pointA!,
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed)));
    });
  }

  void showNearbyTerminalsModal(
    BuildContext context,
    LatLng userLocation,
    List<Terminal> allTerminals,
    double maxDistanceKm,
  ) {
    final List<Terminal> nearbyTerminals = allTerminals.where((terminal) {
      final double distance =
          calculateDistance(userLocation, terminal.location);
      return distance <= maxDistanceKm;
    }).toList();

    nearbyTerminals.sort((a, b) {
      final double distA = calculateDistance(userLocation, a.location);
      final double distB = calculateDistance(userLocation, b.location);
      return distA.compareTo(distB);
    });

    double minDistanceToTerminal = double.infinity;
    if (nearbyTerminals.isNotEmpty) {
      minDistanceToTerminal =
          calculateDistance(userLocation, nearbyTerminals[0].location);
    }

    final double distanceToFinalDest = calculateDistance(userLocation, _pointC);

    if (nearbyTerminals.isNotEmpty &&
        distanceToFinalDest <= minDistanceToTerminal) {
      if (context.mounted) {
        Dialogs.showInfoDialog(
          context,
          title: 'Already Close',
          content:
              'Your starting point is already closer to your destination (${distanceToFinalDest.toStringAsFixed(2)} km) than to the nearest available terminal (${minDistanceToTerminal.toStringAsFixed(2)} km)',
        );
      }
      return;
    } else if (nearbyTerminals.isEmpty) {
      if (context.mounted) {
        Dialogs.showInfoDialog(
          context,
          title: 'No Terminals Found',
          content:
              'Please select a location only in Marikina and we will try our best to search the nearest terminal',
        );
      }
      return;
    } else {
      showModalBottomSheet<Terminal>(
        context: context,
        builder: (BuildContext context) {
          return Container(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'Select a Nearby Terminal',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: nearbyTerminals.length,
                    itemBuilder: (BuildContext context, int index) {
                      final terminal = nearbyTerminals[index];
                      final distance =
                          calculateDistance(userLocation, terminal.location);

                      return ListTile(
                        title: Text(terminal.displayName),
                        subtitle:
                            Text('${distance.toStringAsFixed(2)} km away'),
                        onTap: () {
                          Navigator.pop(context, terminal);
                        },
                      );
                    },
                  ),
                ),
                SizedBox(height: 16),
              ],
            ),
          );
        },
        isScrollControlled: true,
      ).then((selectedTerminal) {
        if (selectedTerminal != null) {
          setState(() {
            _pointB = LatLng(selectedTerminal.location.latitude,
                selectedTerminal.location.longitude);
            _markers.add(Marker(
                markerId: MarkerId('pointB'),
                position: _pointB,
                icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueRed)));
          });

          _addCurvedConnectorLine();
        } else {
          if (context.mounted) {
            Dialogs.showInfoDialog(
              context,
              title: 'Selection Required',
              content:
                  'No terminal was selected. Please try selecting one again.',
            );
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            GoogleMap(
              polylines: _polylines,
              markers: _markers,
              myLocationEnabled: true,
              mapType: MapType.normal,
              initialCameraPosition: _kGooglePlex,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
            ),
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      PlacesAutoCompleteTextFieldWidget(
                          textEditingController: _fromController,
                          getPlaceDetailWithLatLng: _handleFromDetail,
                          itemClick: _handleFromClick,
                          hintText: "Current Location"),
                      SizedBox(height: 12),
                      PlacesAutoCompleteTextFieldWidget(
                        textEditingController: _toController,
                        getPlaceDetailWithLatLng: _handleToDetail,
                        itemClick: _handleToClick,
                      ),
                      SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {
                          if (_pointA == null) {
                            Dialogs.showInfoDialog(context,
                                title: "Information Required",
                                content: "Please fill out all fields");
                          } else {
                            final double searchRadiusKm = 2.0;
                            showNearbyTerminalsModal(
                              context,
                              _pointA!,
                              marikinaTerminals,
                              searchRadiusKm,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: 24, vertical: 16),
                        ),
                        child: Text('Go', style: TextStyle(fontSize: 16)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
