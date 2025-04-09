import 'package:flutter/material.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:map_prototype/components/dialogs.dart';
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
                color: Colors.teal,
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
                  final bool descriptionIsEmpty =
                      _description?.trim().isEmpty ?? true;

                  if (_selectedLatitude == null &&
                      _selectedLongitude == null &&
                      descriptionIsEmpty) {
                    Dialogs.showInfoDialog(
                      context,
                      title: 'Location Required',
                      content: 'Please input the location you are going to.',
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MapSample(
                            latitude: _selectedLatitude ?? 0,
                            longitude: _selectedLongitude ?? 0,
                            destination: _description ?? ''),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      vertical: 14.0, horizontal: 24.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
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
