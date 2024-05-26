// ignore_for_file: avoid_print, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ridemate/services/pushnotificationservice.dart';
import 'dart:convert';

import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const String mapApiKey = "AIzaSyDoCmnLSTMCBPnbqrG3_71ZztjLItFsnfk";

class LocationSelectionPage extends StatefulWidget {
  final String requestId;

  const LocationSelectionPage({Key? key, required this.requestId})
      : super(key: key);

  @override
  _LocationSelectionPageState createState() => _LocationSelectionPageState();
}

class _LocationSelectionPageState extends State<LocationSelectionPage> {
  final TextEditingController _controller = TextEditingController();
  final uuid = const Uuid();
  String _sessionToken = '';
  List<PlacePredModel> _placeList = [];
  String message = '';
  double selectedLocationLatitude = 0.0; // Provide initial values as needed
  double selectedLocationLongitude = 0.0; // Provide initial values as needed

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      _onChanged();
    });
  }

  _onChanged() {
    if (_sessionToken == '') {
      setState(() {
        _sessionToken = uuid.v4();
      });
    }
    getSuggestion(_controller.text);
  }

  Future<void> getSuggestion(String input) async {
    String baseUrl =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json';
    String request =
        '$baseUrl?input=$input&key=$mapApiKey&sessiontoken=$_sessionToken&components=country:pk&components=locality:islamabad';

    try {
      var response = await http.get(Uri.parse(request));
      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result['status'] == 'OK') {
          setState(() {
            message = '';
            _placeList = (result['predictions'] as List)
                .map((prediction) => PlacePredModel.fromJson(prediction))
                .toList();
          });
        } else if (result['status'] == 'ZERO_RESULTS') {
          setState(() {
            message = 'Nothing found';
            _placeList = [];
          });
        }
      } else {
        throw Exception('Failed to fetch suggestion');
      }
    } catch (e) {
      print(e);
    }
  }

  void onLocationSelected(String address, double lat, double lng) {
    // Handle location selection here
    print('Location Selected: $address, $lat, $lng');
  }

  Future<void> _sendNotificationToUser(
      String userId, String startLocation) async {
    try {
      // Get the driver's token from Firestore
      DocumentSnapshot usersnapshot = await FirebaseFirestore.instance
          .collection('users-token')
          .doc(userId)
          .get();

      if (usersnapshot.exists) {
        String? driverToken = usersnapshot['token'];
        if (driverToken != null && driverToken.isNotEmpty) {
          // Send the push notification to the driver
          await PushNotificationService().sendNotification(
            driverToken,
            title: 'Start location Changed',
            bodytxt: 'Driver changed your location to $startLocation!',
          );
        }
      }
    } catch (e) {
      print('Error notifying driver: $e');
    }
  }

  void _updateLocation(String placeId, String description) {
    // Update the location in Firebase
    FirebaseFirestore.instance
        .collection('rideshare-request')
        .doc(widget.requestId)
        .get()
        .then((requestSnapshot) {
      if (requestSnapshot.exists) {
        var requestData = requestSnapshot.data();
        String userId =
            requestData?['userid'] ?? ''; // Fetch userId from request data
        FirebaseFirestore.instance
            .collection('rideshare-request')
            .doc(widget.requestId)
            .update({
          'startlocation': {
            'address': description,
            'latitude': selectedLocationLatitude,
            'longitude': selectedLocationLongitude,
          }
        }).then((_) {
          // Send a notification to the user about the updated location
          _sendNotificationToUser(userId, description);

          // Show a SnackBar with a message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location updated successfully!'),
            ),
          );
          // Return to the previous screen after a short delay
          Future.delayed(const Duration(seconds: 2), () {
            Navigator.pop(context);
          });
        }).catchError((error) {
          // Handle error
          print('Error updating location: $error');
        });
      } else {
        print('Ride request document not found');
      }
    }).catchError((error) {
      print('Error retrieving ride request document: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change start location'),
        backgroundColor: const Color(0xffEDAE10),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: "Search your location here",
              prefixIcon: const Icon(Icons.map),
              suffixIcon: IconButton(
                icon: const Icon(Icons.cancel),
                onPressed: () {
                  _controller.clear();
                },
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _placeList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_placeList[index].description),
                  onTap: () async {
                    await getPlaceDetails(_placeList[index].placeId,
                        _placeList[index].description);
                    // After getting place details, update the location and trigger the update process
                    _updateLocation(_placeList[index].placeId,
                        _placeList[index].description);
                  },
                );
              },
            ),
          ),
          if (message.isNotEmpty)
            Text(
              message,
              style: const TextStyle(color: Colors.red),
            ),
        ],
      ),
    );
  }

  Future<void> getPlaceDetails(String placeId, String description) async {
    String baseUrl = 'https://maps.googleapis.com/maps/api/place/details/json';
    String request = '$baseUrl?placeid=$placeId&key=$mapApiKey';

    try {
      var response = await http.get(Uri.parse(request));
      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result['status'] == 'OK') {
          final placeDetails = result['result'];
          final location = placeDetails['geometry']['location'];
          // Update selected location
          setState(() {
            selectedLocationLatitude = location['lat'];
            selectedLocationLongitude = location['lng'];
          });
          // Call onLocationSelected method
          onLocationSelected(
              description, selectedLocationLatitude, selectedLocationLongitude);
        }
      } else {
        throw Exception('Failed to fetch place details');
      }
    } catch (e) {
      print(e);
    }
  }
}

class PlacePredModel {
  final String placeId;
  final String description;

  PlacePredModel({required this.placeId, required this.description});

  factory PlacePredModel.fromJson(Map<String, dynamic> json) {
    return PlacePredModel(
      placeId: json['place_id'],
      description: json['description'],
    );
  }
}
