import 'package:flutter/material.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:map_prototype/components/placed_autocomplete.dart';
import 'package:map_prototype/pages/maps.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _fromController = TextEditingController();
  final _toController = TextEditingController();
  double? _selectedLatitude;
  double? _selectedLongitude;
  String? _description;
  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  void _handlePlaceDetail(Prediction prediction) {
    if (prediction.lat != null && prediction.lng != null) {
      setState(() {
        _selectedLatitude = double.parse(prediction.lat ?? "0.0");
        _selectedLongitude = double.parse(prediction.lng ?? "0.0");
      });
    } else {
      print("Latitude and Longitude are null for this prediction.");
    }
  }

  void _handleItemClick(Prediction prediction) {
    setState(() {
      _selectedLatitude = double.parse(prediction.lat ?? "0.0");
      _selectedLongitude = double.parse(prediction.lng ?? "0.0");
      _description = prediction.description;
    });

    _toController.text = prediction.description ?? "";
    _toController.selection = TextSelection.fromPosition(
      TextPosition(offset: prediction.description?.length ?? 0),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.25),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Maps:',
              style: TextStyle(
                fontSize: 28.0,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
              textAlign: TextAlign.start,
            ),
            const SizedBox(height: 24.0),
            PlacesAutoCompleteTextFieldWidget(
              textEditingController: _toController,
              getPlaceDetailWithLatLng: _handlePlaceDetail,
              itemClick: _handleItemClick,
            ),
            const SizedBox(height: 24.0),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MapSample(
                          latitude: _selectedLatitude ?? 0, // 14.6260,
                          longitude: _selectedLongitude ?? 0, // 121.0838
                          destination: _description ?? '' // "SM Marikina
                          ),
                    ),
                  );
                  print('Lat: $_selectedLatitude, Long: $_selectedLongitude ');
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14.0),
                  textStyle: const TextStyle(fontSize: 18.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: const Text('Find Directions'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
