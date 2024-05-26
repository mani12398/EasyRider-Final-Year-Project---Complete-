import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ridemate/utils/appcolors.dart';
import 'package:ridemate/view/Authentication/components/customappbar.dart';

class DriverLocationScreen extends StatefulWidget {
  @override
  _DriverLocationScreenState createState() => _DriverLocationScreenState();
}

class _DriverLocationScreenState extends State<DriverLocationScreen> {
  late GoogleMapController _mapController;
  Set<Marker> _markers = {};
  LatLng _driverLocation = LatLng(33.6844, 73.0479); // Default location (Islamabad)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customappbar(context,
          title: 'Driver Live Location', backgroundColor: Appcolors.primaryColor),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _driverLocation,
          zoom: 14,
        ),
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
          _addMarker();
        },
        markers: _markers,
      ),
    );
  }

  void _addMarker() {
    final MarkerId markerId = MarkerId('driver_location');
    final Marker marker = Marker(
      markerId: markerId,
      position: _driverLocation,
      infoWindow: InfoWindow(
        title: 'Driver Live Location',
      ),
    );
    setState(() {
      _markers.add(marker);
    });
  }
}
