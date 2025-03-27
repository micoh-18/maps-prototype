import 'package:flutter/material.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';

class PlacesAutoCompleteTextFieldWidget extends StatefulWidget {
  final TextEditingController textEditingController;
  final Function(Prediction prediction) getPlaceDetailWithLatLng;
  final Function(Prediction prediction) itemClick;
  final String hintText;
  final List<String> countries;

  PlacesAutoCompleteTextFieldWidget({
    required this.textEditingController,
    required this.getPlaceDetailWithLatLng,
    required this.itemClick,
    this.hintText = "Where are you headed to?",
    this.countries = const ["ph"],
  });

  @override
  _PlacesAutoCompleteTextFieldWidgetState createState() =>
      _PlacesAutoCompleteTextFieldWidgetState();
}

class _PlacesAutoCompleteTextFieldWidgetState
    extends State<PlacesAutoCompleteTextFieldWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: GooglePlaceAutoCompleteTextField(
        googleAPIKey: "temp",
        textEditingController: widget.textEditingController,
        inputDecoration: InputDecoration(
          hintText: widget.hintText,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
        ),
        debounceTime: 400,
        countries: widget.countries,
        isLatLngRequired: true,
        getPlaceDetailWithLatLng: widget.getPlaceDetailWithLatLng,
        itemClick: widget.itemClick,
        seperatedBuilder: Divider(),
        containerHorizontalPadding: 10,
        itemBuilder: (context, index, Prediction prediction) {
          return Container(
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                Icon(Icons.location_on),
                SizedBox(width: 7),
                Expanded(child: Text("${prediction.description ?? ""}"))
              ],
            ),
          );
        },
        isCrossBtnShown: true,
      ),
    );
  }
}
