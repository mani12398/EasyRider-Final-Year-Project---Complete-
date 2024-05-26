// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:ridemate/Methods/geofireassistant.dart';
import 'package:ridemate/Methods/mapmethods.dart';
import 'package:ridemate/Providers/homeprovider.dart';
import 'package:ridemate/Providers/useraddressprovider.dart';
import 'package:ridemate/models/directiondetails.dart';
import 'package:ridemate/models/nearbyavailabledrivers.dart';
import 'package:image/image.dart' as images;
import 'package:ridemate/utils/appcolors.dart';
import '../view/Homepage/homepage.dart';

class Mapprovider extends ChangeNotifier {
  List<LatLng> plineCoordinates = [];
  Set<Polyline> polylineset = {};
  late GoogleMapController newgooglemapcontroller;
  Set<Marker> markers = {};
  Completer<GoogleMapController> controller = Completer();
  Future<void> obtainplacedirection(BuildContext context) async {
    final pickup = Provider.of<Pickupaddress>(context, listen: false);
    final destination = Provider.of<Destinationaddress>(context, listen: false);
    final direction = Provider.of<Homeprovider>(context, listen: false);
    markers.removeWhere((element) => element.markerId.value == '1');
    markers.add(
      Marker(
        markerId: const MarkerId('3'),
        position: LatLng(destination.latitude, destination.longitude),
      ),
    );
    markers.add(
      Marker(
        markerId: const MarkerId('2'),
        position: LatLng(pickup.latitude, pickup.longitude),
      ),
    );
    Directiondetails directiondetails = await fetchDirectionDetails(
      LatLng(pickup.latitude, pickup.longitude),
      LatLng(destination.latitude, destination.longitude),
    );
    direction.directiondetails = directiondetails;
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
    notifyListeners();

    LatLngBounds latLngBounds = createLatLngBounds(
      LatLng(pickup.latitude, pickup.longitude),
      LatLng(destination.latitude, destination.longitude),
    );

    newgooglemapcontroller
        .animateCamera(CameraUpdate.newLatLngBounds(latLngBounds, 120));
    direction.calculatefare();
  }

  Future<LocationData> getUserCurrentLocation() async {
    Location location = Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return Future.error('Location services are disabled.');
      }
    }

    permissionGranted = await location.requestPermission();
    if (permissionGranted != PermissionStatus.granted) {
      return Future.error('Location permissions are denied');
    }

    locationData = await location.getLocation();
    return locationData;
  }

  void setposition(BuildContext context) {
    getUserCurrentLocation().then((value) async {
      Provider.of<Homeprovider>(context, listen: false)
          .convertlatlngtoaddress(value);
      Provider.of<Pickupaddress>(context, listen: false)
          .updateaddress(value.latitude!, value.longitude!);
      Uint8List imagebyte = await makeReceiptImage();
      markers.add(
        Marker(
          markerId: const MarkerId('1'),
          position: LatLng(value.latitude!, value.longitude!),
          infoWindow: const InfoWindow(title: 'userlocation'),
          icon: BitmapDescriptor.fromBytes(imagebyte),
        ),
      );
      CameraPosition cameraPosition = CameraPosition(
          target: LatLng(value.latitude!, value.longitude!), zoom: 14.4746);
      final GoogleMapController googleMapController = await controller.future;
      googleMapController
          .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
      notifyListeners();
      initGeofirelistener(context);
    });
  }

  void initGeofirelistener(BuildContext context) {
    final currentpos = Provider.of<Pickupaddress>(context, listen: false);
    Geofire.initialize('availableDrivers');
    Geofire.queryAtLocation(currentpos.latitude, currentpos.longitude, 10)!
        .listen((map) {
      if (map != null) {
        var callBack = map['callBack'];

        switch (callBack) {
          case Geofire.onKeyEntered:
            final nearbyavailabledrivers = Nearbyavailabledrivers(
              key: map['key'],
              latitude: map['latitude'],
              longitude: map['longitude'],
            );
            Geofireassistant.nearbyavailabledriverslist
                .add(nearbyavailabledrivers);
            break;

          case Geofire.onKeyExited:
            Geofireassistant.removedriverfromlist(map['key']);
            removedriveronmap(map['key']);
            break;

          case Geofire.onKeyMoved:
            final nearbyavailabledrivers = Nearbyavailabledrivers(
              key: map['key'],
              latitude: map['latitude'],
              longitude: map['longitude'],
            );
            Geofireassistant.updatedriverlocation(nearbyavailabledrivers);
            updatedriversonmap();
            break;

          case Geofire.onGeoQueryReady:
            updatedriversonmap();
            break;
        }
      }
    });
  }

  void removedriveronmap(String key) {
    markers.removeWhere((element) => element.markerId.value == 'driver$key');
    notifyListeners();
  }

  void resetmarkers() {
    Set<Marker> filteredMarkers = {};

    for (Marker marker in markers) {
      if (marker.markerId.value == '2' || marker.markerId.value == '3') {
        filteredMarkers.add(marker);
      }
    }

    markers = filteredMarkers;

    notifyListeners();
  }

  Future<void> bookeddriverstatus(String rideid, BuildContext context) async {
    try {
      final collection = FirebaseFirestore.instance.collection('RideRequest');
      ByteData imageData = await rootBundle.load('assets/mapcar.png');
      var bytes = Uint8List.view(imageData.buffer);
      var carmapimg = images.decodeImage(bytes);
      carmapimg = images.copyResize(carmapimg!, height: 100, width: 100);
      var byteData = images.encodePng(carmapimg);
      collection.doc(rideid).snapshots().listen((event) {
        if (event.data()!.containsKey('driver_loc')) {
          Map locmap = event['driver_loc'];
          double latitude = double.parse(locmap['latitude'].toString());
          double longitude = double.parse(locmap['longitude'].toString());
          markers
              .removeWhere((element) => element.markerId.value == 'bookdriver');
          markers.add(Marker(
              icon: BitmapDescriptor.fromBytes(byteData),
              markerId: const MarkerId('bookdriver'),
              position: LatLng(latitude, longitude)));
          CameraPosition cameraPosition =
              CameraPosition(target: LatLng(latitude, longitude), zoom: 17);
          newgooglemapcontroller
              .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
          notifyListeners();
        }
      });
    } catch (e) {
      //
    }
  }

  void updatedriversonmap() async {
    ByteData imageData = await rootBundle.load('assets/mapcar.png');
    var bytes = Uint8List.view(imageData.buffer);
    var carmapimg = images.decodeImage(bytes);
    carmapimg = images.copyResize(carmapimg!, height: 100, width: 100);
    var bytedata = images.encodePng(carmapimg);
    for (Nearbyavailabledrivers driver
        in Geofireassistant.nearbyavailabledriverslist) {
      markers.removeWhere(
          (element) => element.markerId.value == 'driver${driver.key}');
    }
    for (Nearbyavailabledrivers driver
        in Geofireassistant.nearbyavailabledriverslist) {
      Marker marker = Marker(
        markerId: MarkerId('driver${driver.key}'),
        position: LatLng(driver.latitude, driver.longitude),
        rotation: Random().nextInt(360).toDouble(),
        icon: BitmapDescriptor.fromBytes(bytedata),
      );
      markers.add(marker);
    }
    notifyListeners();
  }
}
