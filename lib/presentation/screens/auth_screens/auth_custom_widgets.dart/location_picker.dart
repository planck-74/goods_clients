import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goods_clients/business_logic/cubits/client_data/controller_cubit.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class LocationPickerScreen extends StatefulWidget {
  final LatLng? initialPosition;

  const LocationPickerScreen({super.key, this.initialPosition});

  @override
  _LocationPickerScreenState createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  late LatLng _selectedLocation = const LatLng(30.0444, 31.2357);
  late GoogleMapController _mapController;
  late Location _location;
  late LatLng _currentLocation = const LatLng(30.0444, 31.2357);
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _location = Location();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final currentLocation = await _location.getLocation();
      setState(() {
        _currentLocation =
            LatLng(currentLocation.latitude!, currentLocation.longitude!);
        _selectedLocation =
            _currentLocation; 
        _isLoading = false; 
      });
    } catch (e) {
      setState(() {
        _isLoading = false; 
      });
    }
  }

  void _onMapTapped(LatLng location) {
    setState(() {
      _selectedLocation = location;
    });
  }

  void _goToCurrentLocation() {
    _mapController.animateCamera(
      CameraUpdate.newLatLng(_currentLocation),
    );
    setState(() {
      _selectedLocation = _currentLocation;
    });
  }

  @override
  Widget build(BuildContext context) {
    final LatLng initialPosition =
        widget.initialPosition ?? const LatLng(30.0444, 31.2357);
    return Scaffold(
      body: Center(
        child: SizedBox(
          height: 500, 
          width: double.infinity, 
          child: Stack(
            children: [
              if (!_isLoading)
                GoogleMap(
                  zoomControlsEnabled: false,
                  initialCameraPosition: CameraPosition(
                    target: initialPosition,
                    zoom: 12,
                  ),
                  onMapCreated: (GoogleMapController controller) {
                    _mapController = controller;
                  },
                  onTap: _onMapTapped,
                  markers: {
                    Marker(
                      markerId: const MarkerId('selected-location'),
                      position: _selectedLocation,
                    ),
                  },
                ),
              if (_isLoading)
                const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF012340),
                    strokeWidth: 3,
                  ),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: _isLoading
          ? null
          : Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  onPressed: () {
                    if (_selectedLocation != initialPosition) {
                      context.read<ControllerCubit>().geoPoint = GeoPoint(
                          _selectedLocation.latitude,
                          _selectedLocation.longitude);

                      final overlay = Overlay.of(context);
                      final overlayEntry = OverlayEntry(
                        builder: (context) => Positioned(
                          top: MediaQuery.of(context).padding.top +
                              10, 
                          left: 20,
                          right: 20,
                          child: Material(
                            color: Colors.transparent,
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Text(
                                'تم تحديد الموقع بنجاح!',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      );

                      overlay.insert(overlayEntry);
                      Future.delayed(const Duration(seconds: 3), () {
                        overlayEntry.remove();
                      });
                    }
                  },
                  backgroundColor: const Color.fromARGB(255, 51, 202, 17),
                  heroTag: null,
                  mini: true, 
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 20, 
                  ),
                ),
                const SizedBox(height: 6),
                FloatingActionButton(
                  onPressed: _goToCurrentLocation,
                  backgroundColor: const Color(0xFF012340),
                  heroTag: null,
                  mini: true, 
                  child: const Icon(
                    Icons.my_location,
                    color: Colors.white,
                    size: 20, 
                  ),
                ),
              ],
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
