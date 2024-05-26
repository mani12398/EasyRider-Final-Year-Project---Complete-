import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image/image.dart' as images;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:ridemate/Methods/mapkitassistant.dart';
import 'package:ridemate/Methods/mapmethods.dart';
import 'package:ridemate/models/ridedetails.dart';
import 'package:ridemate/utils/appcolors.dart';
import '../models/directiondetails.dart';

class DriverRideProivder extends ChangeNotifier {
  final Set<Marker> markersSet = <Marker>{};
  final Set<Polyline> polylineset = {};
  final List<LatLng> plineCoordinates = [];
  late final GoogleMapController newgooglemapcontroller;
  late StreamSubscription<LocationData> ridestreamsubscription;
  late LocationData currentPosition;
  String btntxt = 'Arrived';
  String durationText = '';
  bool isRequesting = true;
  late Timer timer;
  int durationcounter = 0;

  void initcounter() {
    const interval = Duration(minutes: 1);
    timer = Timer.periodic(interval, (timer) {
      durationcounter += 1;
    });
  }

  void endtrip() {
    ridestreamsubscription.cancel();
    timer.cancel();
  }

  void changebtntxt(String text) {
    btntxt = text;
    notifyListeners();
  }

  void savecurrentLocation(String rideid) {
    FirebaseFirestore.instance.collection('RideRequest').doc(rideid).set({
      'driver_loc': {
        'latitude': currentPosition.latitude,
        'longitude': currentPosition.longitude,
      },
    }, SetOptions(merge: true));
  }

  Future<void> setcurrentPosition() async {
    Location location = Location();
    currentPosition = await location.getLocation();
  }

  Future<void> getPlaceDirection(
      LatLng pickUpLatLng, LatLng dropoffLatLng) async {
    Directiondetails directiondetails =
        await fetchDirectionDetails(pickUpLatLng, dropoffLatLng);

    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> decodedPolylinePointsResult =
        polylinePoints.decodePolyline(directiondetails.encodedpoints);
    plineCoordinates.clear();
    if (decodedPolylinePointsResult.isNotEmpty) {
      for (var pointLatLng in decodedPolylinePointsResult) {
        plineCoordinates
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      }
    }
    Polyline polyline = Polyline(
      polylineId: const PolylineId('polylineid'),
      color: Appcolors.primaryColor,
      jointType: JointType.round,
      points: plineCoordinates,
      width: 5,
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
      geodesic: true,
    );
    polylineset.clear();
    polylineset.add(polyline);

    LatLngBounds latLngBounds = createLatLngBounds(
      pickUpLatLng,
      dropoffLatLng,
    );
    markersSet.removeWhere((element) =>
        element.markerId.value == 'pickup' || element.markerId.value == 'dest');
    newgooglemapcontroller
        .animateCamera(CameraUpdate.newLatLngBounds(latLngBounds, 140));
    Marker pickuplocmarker = Marker(
      markerId: const MarkerId('pickup'),
      position: pickUpLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );
    Marker destlocmarker = Marker(
      markerId: const MarkerId('dest'),
      position: dropoffLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );
    markersSet.add(pickuplocmarker);
    markersSet.add(destlocmarker);
    notifyListeners();
  }

  Future<void> animatedrivercar(RideDetails rideDetails) async {
    Location location = Location();
    ByteData imageData = await rootBundle.load('assets/mapcar.png');
    var bytes = Uint8List.view(imageData.buffer);
    var carmapimg = images.decodeImage(bytes);
    carmapimg = images.copyResize(carmapimg!, height: 100, width: 100);
    var bytedata = images.encodePng(carmapimg);
    LatLng oldpos = const LatLng(0, 0);
    ridestreamsubscription = location.onLocationChanged.listen((pos) {
      FirebaseFirestore.instance
          .collection('RideRequest')
          .doc(rideDetails.rideid)
          .update({
        'driver_loc': {
          'latitude': pos.latitude,
          'longitude': pos.longitude,
        },
      });
      LatLng newpos = LatLng(pos.latitude!, pos.longitude!);
      currentPosition = pos;
      var rot = MapkitAssistant.getMarkerRotation(
          oldpos.latitude, oldpos.longitude, newpos.latitude, newpos.longitude);
      Marker animatingmarker = Marker(
        markerId: const MarkerId('animating'),
        position: newpos,
        infoWindow: const InfoWindow(title: 'currentlocation'),
        icon: BitmapDescriptor.fromBytes(bytedata),
        rotation: rot.toDouble(),
      );
      CameraPosition cameraPosition = CameraPosition(target: newpos, zoom: 17);
      newgooglemapcontroller
          .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
      markersSet
          .removeWhere((element) => element.markerId.value == 'animating');
      markersSet.add(animatingmarker);
      notifyListeners();
      oldpos = newpos;
      updaterideduration(rideDetails);
    });
  }

  void updaterideduration(RideDetails rideDetails) async {
    if (isRequesting) {
      isRequesting = false;
      LatLng destlatlng;
      if (btntxt == 'Arrived') {
        destlatlng = rideDetails.pickup;
      } else {
        destlatlng = rideDetails.dropoff;
      }
      var directiondetails = await fetchDirectionDetails(
          LatLng(currentPosition.latitude!, currentPosition.longitude!),
          destlatlng);
      durationText = directiondetails.durationtext;
      notifyListeners();
      FirebaseFirestore.instance
          .collection('RideRequest')
          .doc(rideDetails.rideid)
          .update({
        'rideDuration': {
          'duration': durationText,
          'distance': directiondetails.distancetext,
        }
      });
      isRequesting = true;
    }
  }
}
