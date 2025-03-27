import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:map_prototype/components/placed_autocomplete.dart';

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

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(14.650445836519411, 121.10234552274542),
    zoom: 13,
  );

  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  LatLng? _currentLocation;
  final TextEditingController _fromController = TextEditingController();
  final Set<Marker> _markers = {};
  late LatLng _pointA;
  late LatLng _pointB;
  final Set<Polyline> _polylines = {};
  final TextEditingController _toController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _pointA = LatLng(widget.latitude, widget.longitude);
    _pointB = LatLng(14.6345177, 121.1156694);
    _markers.add(Marker(
        markerId: MarkerId('pointA'),
        position: _pointA,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed)));
    _markers.add(Marker(
        markerId: MarkerId('pointB'),
        position: _pointB,
        icon:
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen)));
    _fromController.text = widget.destination;
  }

  Future<void> _addCurvedConnectorLine() async {
    mapController = await _controller.future;

    print(_pointA);
    print(_pointB);
    List<LatLng> curvedPoints = _createCurvedPoints(_pointA, _pointB);

    setState(() {
      _polylines.add(
        Polyline(
          polylineId: PolylineId('curvedConnector'),
          points: curvedPoints,
          color: Colors.blue,
          width: 5,
        ),
      );
    });

    // Optionally, move the camera to fit the curve
    LatLngBounds bounds = _boundsFromLatLngList(curvedPoints);
    mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
  }

  List<LatLng> _createCurvedPoints(LatLng start, LatLng end,
      {int numPoints = 20}) {
    List<LatLng> points = [];
    points.add(start);

    // Control point for the curve (you can customize this)
    LatLng controlPoint = LatLng(
      (start.latitude + end.latitude) / 2,
      (start.longitude + end.longitude) / 2 + 0.01, // Adjust for curve height
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
      // Handle the latitude and longitude here
    } else {
      print("Latitude and Longitude are null for this prediction.");
    }
  }

// Latitude: 14.6345177, Longitude: 121.0983782
  void _handleToClick(Prediction prediction) {
    _toController.text = prediction.description ?? "";
    _toController.selection = TextSelection.fromPosition(
      TextPosition(offset: prediction.description?.length ?? 0),
    );
  }

  void _handleFromClick(Prediction prediction) {
    _fromController.text = prediction.description ?? "";
    _fromController.selection = TextSelection.fromPosition(
      TextPosition(offset: prediction.description?.length ?? 0),
    );
    setState(() {
      _pointA = LatLng(double.parse(prediction.lat ?? "0.0"),
          double.parse(prediction.lng ?? "0.0"));
    });
    _markers.add(Marker(
        markerId: MarkerId('pointA'),
        position: _pointA,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed)));
  }

  void showItemListModal(BuildContext context, List<String> items) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'Select an Item',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                itemCount: items.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    title: Text(items[index]),
                    onTap: () {
                      // Handle item selection here
                      Navigator.pop(context,
                          items[index]); // Close modal and return selected item
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    ).then((selectedItem) {
      if (selectedItem != null) {
        // Handle the selected item, e.g., update UI or perform an action
        print('Selected Item: $selectedItem');
      }
    });
  }

  void _handleFromDetail(Prediction prediction) {
    if (prediction.lat != null && prediction.lng != null) {
      print("Latitude: ${prediction.lat}, Longitude: ${prediction.lng}");
      // Handle the latitude and longitude here
    } else {
      print("Latitude and Longitude are null for this prediction.");
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
              top: 16.0, // Add top padding for the title
              left: 16.0,
              right: 16.0,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(16.0), // Increase padding
                  child: Text(
                    'Maps',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 16, // Increase bottom padding
              left: 16,
              right: 16,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(16.0), // Increase padding
                  child: Column(
                    children: [
                      PlacesAutoCompleteTextFieldWidget(
                        textEditingController: _fromController,
                        getPlaceDetailWithLatLng: _handleFromDetail,
                        itemClick: _handleFromClick,
                      ),
                      SizedBox(height: 12),
                      PlacesAutoCompleteTextFieldWidget(
                        textEditingController: _toController,
                        getPlaceDetailWithLatLng: _handleToDetail,
                        itemClick: _handleToClick,
                      ),
                      SizedBox(height: 12), // Increase spacing
                      ElevatedButton(
                        onPressed: () {
                          _addCurvedConnectorLine();
                          showItemListModal(context, []);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: 24, vertical: 16), // Increase padding
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
