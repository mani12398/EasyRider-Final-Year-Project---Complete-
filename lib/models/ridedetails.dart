import 'package:google_maps_flutter/google_maps_flutter.dart';

class RideDetails {
  String pickupaddress;
  String destinationaddress;
  LatLng pickup;
  LatLng dropoff;
  String ridername;
  String rideid;
  int ridefare;
  RideDetails({
    required this.pickupaddress,
    required this.destinationaddress,
    required this.pickup,
    required this.dropoff,
    required this.ridername,
    required this.rideid,
    this.ridefare = 0,
  });
}
