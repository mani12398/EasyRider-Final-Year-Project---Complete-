// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:ridemate/Providers/userdataprovider.dart';
import '../routing/routing.dart';
import '../view/Authentication/view/Driver/driverscreen.dart';
import '../view/Dialogueboxes/congratdialogue.dart';

Future<bool> checkAllFieldsExist(String userId) async {
  final driversCollection = FirebaseFirestore.instance.collection('drivers');

  final DocumentSnapshot docSnapshot =
      await driversCollection.doc(userId).get();

  if (docSnapshot.exists) {
    final data = docSnapshot.data() as Map<String, dynamic>;
    return data.containsKey('Driver Licence Frontside') &&
        data.containsKey('Driver Licence Backside') &&
        data.containsKey('Cnicno') &&
        data.containsKey('CNIC Frontside') &&
        data.containsKey('CNIC Backside') &&
        data.containsKey('Selfie with ID') &&
        data.containsKey('Basic Info') &&
        data.containsKey('Photo of Vehicle') &&
        data.containsKey('Vehicle Registration Frontside') &&
        data.containsKey('Vehicle Registration Backside') &&
        data.containsKey('Vehicle_Number') &&
        data.containsKey('Transportname');
  } else {
    return false;
  }
}

Future<void> checkit(String userId, BuildContext context) async {
  if (await checkAllFieldsExist(userId)) {
    final myprovider = Provider.of<Userdataprovider>(context, listen: false);
    await congratdialogue(context);
    FirebaseFirestore.instance.collection('drivers').doc(userId).set({
      'Status': 'InReview',
      'Gender': myprovider.userData['Gender'],
      'Name': myprovider.userData['Username'],
      'Email': myprovider.userData['Email'],
      'Phonenumber': myprovider.userData['phoneNumber'],
    }, SetOptions(merge: true));
    navigateandremove(context, Driverscreen());
  } else {
    Navigator.pop(context);
  }
}

late StreamSubscription<LocationData> streamSubscription;

void changedriverstatus(BuildContext context, bool isOnline) async {
  if (isOnline) {
    String id = Provider.of<Userdataprovider>(context, listen: false).userId;
    DatabaseReference reference = FirebaseDatabase.instance.ref().child(id);
    Location location = Location();
    LocationData position = await location.getLocation();
    Geofire.initialize('availableDrivers');
    Geofire.setLocation(id, position.latitude!, position.longitude!);
    reference.onValue.listen((event) {});
    streamSubscription = location.onLocationChanged.listen((position) {
      Geofire.setLocation(id, position.latitude!, position.longitude!);
    });
  } else {
    String id = Provider.of<Userdataprovider>(context, listen: false).userId;
    DatabaseReference reference = FirebaseDatabase.instance.ref().child(id);
    Geofire.removeLocation(id);
    reference.onDisconnect();
    reference.remove();
    streamSubscription.cancel();
  }
}

void pausehometablivelocation(BuildContext context) {
  String id = Provider.of<Userdataprovider>(context, listen: false).userId;
  streamSubscription.pause();
  Geofire.removeLocation(id);
}

Future<void> resumehometablivelocation(BuildContext context) async {
  Location location = Location();
  LocationData position = await location.getLocation();
  String id = Provider.of<Userdataprovider>(context, listen: false).userId;
  streamSubscription.resume();
  Geofire.setLocation(id, position.latitude!, position.longitude!);
}
