import 'dart:convert';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ridemate/utils/api_credential.dart';

import '../models/directiondetails.dart';
import 'package:http/http.dart' as http;

Future<Directiondetails> fetchDirectionDetails(
    LatLng origin, LatLng destination) async {
  String url =
      'https://maps.googleapis.com/maps/api/directions/json?destination=${destination.latitude},${destination.longitude}&origin=${origin.latitude},${origin.longitude}&key=$mapapikey';
  var response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    final res = json.decode(response.body);
    if (res['status'] == 'OK') {
      return Directiondetails(
        distancevalue: res['routes'][0]['legs'][0]['distance']['value'],
        distancetext: res['routes'][0]['legs'][0]['distance']['text'],
        durationtext: res['routes'][0]['legs'][0]['duration']['text'],
        durationvalue: res['routes'][0]['legs'][0]['duration']['value'],
        encodedpoints: res['routes'][0]['overview_polyline']['points'],
      );
    } else {
      throw Exception('Failed to fetch direction details');
    }
  } else {
    throw Exception('Failed to load direction details');
  }
}

LatLngBounds createLatLngBounds(LatLng pickup, LatLng destination) {
  LatLngBounds latLngBounds;
  if (pickup.latitude > destination.latitude &&
      pickup.longitude > destination.longitude) {
    latLngBounds = LatLngBounds(
      southwest: LatLng(destination.latitude, destination.longitude),
      northeast: LatLng(pickup.latitude, pickup.longitude),
    );
  } else if (pickup.longitude > destination.longitude) {
    latLngBounds = LatLngBounds(
      southwest: LatLng(pickup.latitude, destination.longitude),
      northeast: LatLng(destination.latitude, pickup.longitude),
    );
  } else if (pickup.latitude > destination.latitude) {
    latLngBounds = LatLngBounds(
      southwest: LatLng(destination.latitude, pickup.longitude),
      northeast: LatLng(pickup.latitude, destination.longitude),
    );
  } else {
    latLngBounds = LatLngBounds(
      southwest: LatLng(pickup.latitude, pickup.longitude),
      northeast: LatLng(destination.latitude, destination.longitude),
    );
  }
  return latLngBounds;
}
