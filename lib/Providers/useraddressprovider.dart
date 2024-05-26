// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ridemate/Providers/homeprovider.dart';
import 'package:ridemate/Providers/mapprovider.dart';
import 'package:ridemate/utils/api_credential.dart';
import 'package:http/http.dart' as http;

class Pickupaddress extends ChangeNotifier {
  double latitude = 0.0;
  double longitude = 0.0;
  void updateaddress(double lat, double lon) {
    latitude = lat;
    longitude = lon;
  }

  Future<void> updatebyapi(String placeid, BuildContext context) async {
    String url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeid&key=$mapapikey';
    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final res = json.decode(response.body);
      if (res['status'] == 'OK') {
        latitude = res['result']['geometry']['location']['lat'];
        longitude = res['result']['geometry']['location']['lng'];
        Navigator.pop(context);
        if (Provider.of<Homeprovider>(context, listen: false).destination !=
            'Destination') {
          Provider.of<Mapprovider>(context, listen: false)
              .obtainplacedirection(context);
        }
      }
    }
  }
}

class Destinationaddress extends ChangeNotifier {
  double latitude = 0.0;
  double longitude = 0.0;
  Future<void> updateaddress(String placeid, BuildContext context) async {
    String url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeid&key=$mapapikey';
    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final res = json.decode(response.body);
      if (res['status'] == 'OK') {
        latitude = res['result']['geometry']['location']['lat'];
        longitude = res['result']['geometry']['location']['lng'];
        Navigator.pop(context);
        Provider.of<Mapprovider>(context, listen: false)
            .obtainplacedirection(context);
      }
    }
  }
}
