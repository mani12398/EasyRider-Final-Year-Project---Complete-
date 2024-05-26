// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ridemate/Methods/geofireassistant.dart';
import 'package:ridemate/Providers/homeprovider.dart';
import 'package:ridemate/Providers/useraddressprovider.dart';
import 'package:ridemate/Providers/userdataprovider.dart';
import 'package:ridemate/models/nearbyavailabledrivers.dart';
import 'package:ridemate/services/pushnotificationservice.dart';
import 'package:ridemate/view/Homepage/components/rides.dart';

class Bookingprovider extends ChangeNotifier {
  String rideid = '';
  bool loading = false;
  bool enabledbutton = false;

  void checkifempty(BuildContext context) {
    final homeprovider = Provider.of<Homeprovider>(context, listen: false);
    if (homeprovider.destination != 'Destination') {
      enabledbutton = true;
      notifyListeners();
    }
  }

  void saveRideRequest(BuildContext context) {
    loading = true;
    notifyListeners();
    final docref = FirebaseFirestore.instance.collection('RideRequest').doc();
    final pickup = Provider.of<Pickupaddress>(context, listen: false);
    final destination = Provider.of<Destinationaddress>(context, listen: false);
    final addressdetail = Provider.of<Homeprovider>(context, listen: false);
    final user = Provider.of<Userdataprovider>(context, listen: false);
    rideid = docref.id;
    docref.set({
      'pickup': {
        'latitude': pickup.latitude,
        'longitude': pickup.longitude,
      },
      'dropoff': {
        'latitude': destination.latitude,
        'longitude': destination.longitude,
      },
      'userid': Provider.of<Userdataprovider>(context, listen: false).userId,
      'created_at': DateTime.now(),
      'rider_name': user.userData['Username'],
      'pickup_address': addressdetail.address,
      'destination_address': addressdetail.destination,
      'ridefare': addressdetail.faretext,
      'driversdata': [],
      'requestdrivers': [],
      'Status': 'Pending',
      'rideDuration': {},
    });
  }

  void sendfcm(String token) async {
    PushNotificationService service = PushNotificationService();
    await service.sendNotification(
      token,
      rideid: rideid,
      title: "New Ride Request",
      bodytxt: "You have a new ride request.",
    );
  }

  Future<void> sendRideRequesttoNearestDriver(
      String gender, BuildContext context, bool ridemode) async {
    for (Nearbyavailabledrivers driver
        in Geofireassistant.nearbyavailabledriverslist) {
      final doc = await FirebaseFirestore.instance
          .collection('drivers')
          .doc(driver.key)
          .get();

      if (ridemode) {
        if (doc['Gender'] == gender) {
          String token = doc['token'];
          sendfcm(token);
        }
      } else {
        String token = doc['token'];
        sendfcm(token);
      }
    }
    loading = false;
    notifyListeners();
    showridebottomsheet(context, rideid);
  }
}
