import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:location/location.dart';
import 'package:ridemate/models/directiondetails.dart';
import 'package:ridemate/models/placepredmodel.dart';
import 'package:ridemate/utils/api_credential.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

class Homeprovider extends ChangeNotifier {
  bool showicon = false;
  List<Placepredmodel> suggestionlist = [];
  String message = '';
  String address = '';
  String destination = 'Destination';
  int selectedindex = 0;
  int faretext = 0;
  double actualfare = 0;
  Directiondetails directiondetails = Directiondetails();
  bool showsheet = false;
  double rating = 0;

  void changecategory(int ind) {
    selectedindex = ind;
    notifyListeners();
  }

  void setemptyaddress() {
    address = '';
    notifyListeners();
  }

  void showbooksheet(double rat) {
    showsheet = true;
    rating = rat;
    notifyListeners();
  }

  void userselectedfare(int fare) {
    faretext = fare;
    notifyListeners();
  }

  void calculatefare() {
    if (directiondetails.distancetext != '') {
      double timeTraveledFare = (directiondetails.durationvalue / 60) * 0.10;
      double distanceTraveledFare =
          (directiondetails.distancevalue / 1000) * 0.10;
      int totalfare =
          ((timeTraveledFare + distanceTraveledFare) * 140).truncate();
      if (selectedindex == 1) {
        faretext = totalfare + 200;
      } else if (selectedindex == 2) {
        faretext = totalfare + 350;
      } else if (selectedindex == 3) {
        faretext = (totalfare / 2).truncate();
      } else {
        faretext = totalfare;
      }
      notifyListeners();
      actualfare = faretext.toDouble();
    }
  }

  void changeiconvisibility(int length) {
    if (length > 0) {
      showicon = true;
      notifyListeners();
    } else {
      showicon = false;
      suggestionlist = [];
      notifyListeners();
    }
  }

  void changedest(String dest) {
    destination = dest;
    notifyListeners();
  }

  void changepickup(String pick) {
    address = pick;
    notifyListeners();
  }

  Future<void> convertlatlngtoaddress(LocationData position) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude!, position.longitude!);
    address =
        "${placemarks.reversed.last.street}(${placemarks.reversed.last.subLocality})";
    notifyListeners();
  }

  Future<void> getsuggesstion(String input) async {
    String baseurl =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json';
    String sessiontoken = const Uuid().v4();
    String request =
        '$baseurl?input=$input&key=$mapapikey&sessiontoken=$sessiontoken&components=country:pk';

    var response = await http.get(Uri.parse(request));
    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['status'] == 'OK') {
        message = '';
        List predictions = result['predictions'];
        suggestionlist =
            (predictions).map((j) => Placepredmodel.fromjson(j)).toList();
        notifyListeners();
      }
      if (result['status'] == 'ZERO_RESULTS') {
        message = 'nothingfound';
        notifyListeners();
      }
    } else {
      throw Exception('Failed to fetch suggestion');
    }
  }
}
