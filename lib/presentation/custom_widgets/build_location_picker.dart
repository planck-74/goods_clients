import 'package:flutter/material.dart';
import 'package:goods_clients/presentation/screens/auth_screens/auth_custom_widgets.dart/location_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

Widget buildLocationPicker({required double width, LatLng? initialPosition}) {
  final LatLng Position = initialPosition ?? const LatLng(30.0444, 31.2357);
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Container(
      height: 250,
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: LocationPickerScreen(
        initialPosition: Position,
      ),
    ),
  );
}
