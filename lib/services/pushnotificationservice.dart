// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:googleapis_auth/auth_io.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:provider/provider.dart';
import 'package:ridemate/routing/routing.dart';
import 'package:ridemate/view/Authentication/view/Driver/driverridescreen.dart';
import 'package:ridemate/Methods/drivermethods.dart';
import 'package:ridemate/view/Authentication/view/Driver/ridecontainer.dart';
import 'package:ridemate/view/Dialogueboxes/progressdialogue.dart';
import '../Providers/userdataprovider.dart';
import '../models/ridedetails.dart';

Future<String> getAccessToken() async {
  // Load the service account credentials from the JSON key file
  final jsonString = await rootBundle.loadString('assets/service-account.json');
  final serviceAccountCredentials =
      ServiceAccountCredentials.fromJson(jsonString);

  var scopes = ['https://www.googleapis.com/auth/cloud-platform'];

  // Create an authorized client
  final client =
      await clientViaServiceAccount(serviceAccountCredentials, scopes);

  // Obtain the access token
  final accessToken = client.credentials.accessToken;
  print('Access token is ${accessToken.data}');
  return accessToken.data;
}

class PushNotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init(BuildContext context) async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      if (message.notification?.title == "New Ride Request") {
        saverequestdriver(context, message);
        displayNotification(message);
      } else if (message.notification?.title == "Get Ready") {
        displayNotification(message);
        offerfaretimer.cancel();
        hideProgressDialog(context);
        final ridedetails = await retrieveRideRequestDetail(message);
        pausehometablivelocation(context);
        navigateToScreen(context, DriverRideScreen(rideDetails: ridedetails));
      } else if (message.notification?.title == "Ride Cancelled") {
        displayNotification(message);
        startcancelsubs(context, message.data['ride_request_id']);
      } else {
        displayNotification(message);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("onMessageOpenedApp: $message");
    });
  }

  Future<RideDetails> retrieveRideRequestDetail(RemoteMessage message) async {
    final ridedetail = await FirebaseFirestore.instance
        .collection('RideRequest')
        .doc(message.data['ride_request_id'])
        .get();
    RideDetails rideDetails = RideDetails(
      rideid: message.data['ride_request_id'],
      pickupaddress: ridedetail['pickup_address'],
      destinationaddress: ridedetail['destination_address'],
      pickup: LatLng(
        double.parse(ridedetail['pickup']['latitude'].toString()),
        double.parse(ridedetail['pickup']['longitude'].toString()),
      ),
      dropoff: LatLng(
        double.parse(ridedetail['dropoff']['latitude'].toString()),
        double.parse(ridedetail['dropoff']['longitude'].toString()),
      ),
      ridername: ridedetail['rider_name'],
      ridefare: ridedetail['ridefare'],
    );
    return rideDetails;
  }

  void saverequestdriver(BuildContext context, RemoteMessage message) async {
    String id = message.data['ride_request_id'];
    final docRef = FirebaseFirestore.instance.collection('RideRequest').doc(id);
    final driverid =
        Provider.of<Userdataprovider>(context, listen: false).userId;
    List newData = [driverid];
    await docRef.update({
      'requestdrivers': FieldValue.arrayUnion(newData),
    });
  }

  Future<String?> getToken() async {
    String? token = await _firebaseMessaging.getToken();
    print('token is $token');
    return token;
  }

  void refreshtoken(CollectionReference firestore, String docid) {
    _firebaseMessaging.onTokenRefresh.listen((event) {
      firestore.doc(docid).update({'token': event});
    });
  }

  Future<void> displayNotification(RemoteMessage message) async {
    try {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'your_channel_id',
        'your_channel_name',
        channelDescription: 'your_channel_description',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: false,
      );
      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);
      await flutterLocalNotificationsPlugin.show(
        0,
        message.notification?.title,
        message.notification?.body,
        platformChannelSpecifics,
        payload: message.data.toString(),
      );
    } catch (e) {
      print('Error displaying notification: $e');
    }
  }

  Future<void> sendNotification(
    String token, {
    String rideid = '',
    required String title,
    required String bodytxt,
  }) async {
    String oauthid = await getAccessToken();
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $oauthid',
    };

    var body = jsonEncode({
      "message": {
        "token": token,
        "notification": {"title": title, "body": bodytxt},
        "data": {"status": "processed", 'ride_request_id': rideid}
      }
    });
    try {
      var response = await http.post(
        Uri.parse(
            'https://fcm.googleapis.com/v1/projects/ridemate-7d7f7/messages:send'),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        print('_________message sent_______________');
      } else {
        print('_________message not sent_______________');
      }
    } catch (e) {
      print('______error is ${e.toString()}_______');
    }
  }
}
