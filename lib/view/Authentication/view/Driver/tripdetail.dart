import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:ridemate/models/ridedetails.dart';
import 'package:ridemate/utils/appcolors.dart';
import 'package:ridemate/view/Authentication/view/Driver/ridecontainer.dart';
import 'package:ridemate/widgets/custombutton.dart';
import 'package:ridemate/widgets/customtext.dart';
import 'package:ridemate/widgets/spacing.dart';
import 'package:image/image.dart' as images;
import '../../../../Methods/mapmethods.dart';

class TripDetail extends StatefulWidget {
  final String duration, distance;
  final int fare;
  final RideDetails rideDetails;
  const TripDetail(
      {super.key,
      required this.duration,
      required this.distance,
      required this.fare,
      required this.rideDetails});

  @override
  State<TripDetail> createState() => _TripDetailState();
}

class _TripDetailState extends State<TripDetail> {
  final CameraPosition _kGooglePlex =
      const CameraPosition(target: LatLng(33.6941, 72.9734), zoom: 14.4746);
  final Set<Marker> markersSet = <Marker>{};
  final Set<Polyline> polylineset = {};
  final List<LatLng> plineCoordinates = [];
  final Completer<GoogleMapController> mapcontroller = Completer();
  late final GoogleMapController newgooglemapcontroller;

  Future<void> getPlacedetail(BuildContext context) async {
    ByteData imageData = await rootBundle.load('assets/mapcar.png');
    var bytes = Uint8List.view(imageData.buffer);
    var carmapimg = images.decodeImage(bytes);
    carmapimg = images.copyResize(carmapimg!, height: 100, width: 100);
    var bytedata = images.encodePng(carmapimg);
    Location location = Location();
    final loc = await location.getLocation();
    final loclatlng = LatLng(loc.latitude!, loc.longitude!);
    final dirdetails = await fetchDirectionDetails(
        widget.rideDetails.pickup, widget.rideDetails.dropoff);
    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> decodedPolylinePointsResult =
        polylinePoints.decodePolyline(dirdetails.encodedpoints);
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

    Marker pickuplocmarker = Marker(
      markerId: const MarkerId('pickup'),
      position: widget.rideDetails.pickup,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      infoWindow: const InfoWindow(title: 'pickup'),
    );
    Marker destlocmarker = Marker(
      markerId: const MarkerId('destination'),
      position: widget.rideDetails.dropoff,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      infoWindow: const InfoWindow(title: 'destination'),
    );

    Marker currentposmarker = Marker(
      markerId: const MarkerId('currentpositon'),
      position: widget.rideDetails.dropoff,
      icon: BitmapDescriptor.fromBytes(bytedata),
      infoWindow: const InfoWindow(title: 'currentpositon'),
    );
    markersSet.add(pickuplocmarker);
    markersSet.add(destlocmarker);
    markersSet.add(currentposmarker);

    LatLngBounds latLngBounds =
        createLatLngBounds(loclatlng, widget.rideDetails.dropoff);
    newgooglemapcontroller
        .animateCamera(CameraUpdate.newLatLngBounds(latLngBounds, 120));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(bottom: 330.h),
            initialCameraPosition: _kGooglePlex,
            zoomControlsEnabled: false,
            onMapCreated: (controller) async {
              mapcontroller.complete(controller);
              newgooglemapcontroller = controller;
              await getPlacedetail(context);
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            markers: Set<Marker>.of(markersSet),
            polylines: polylineset,
          ),
          Positioned(
            left: 0,
            top: 37,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 220.h,
            child: Container(
              padding: const EdgeInsets.only(
                  bottom: 10, top: 10, left: 15, right: 10),
              decoration: const BoxDecoration(
                color: Appcolors.contentSecondary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.location_on, color: Colors.white),
                    title: CustomText(
                      title: widget.rideDetails.pickupaddress,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.location_on, color: Colors.white),
                    title: CustomText(
                      title: widget.rideDetails.destinationaddress,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 220.h,
              padding: const EdgeInsets.only(
                  bottom: 20, top: 15, left: 15, right: 10),
              color: Appcolors.contentPrimary,
              child: Column(
                children: [
                  Custombutton(
                    text: 'Accept for ${widget.fare}PKR',
                    fontSize: 18,
                    ontap: () {
                      savedriverid(context, widget.rideDetails.rideid,
                          widget.duration, widget.distance, widget.fare);
                    },
                  ),
                  addVerticalspace(height: 22.h),
                  const CustomText(
                    title: 'Offer your Fare:',
                    textAlign: TextAlign.center,
                    color: Colors.white,
                    fontSize: 20,
                  ),
                  const Spacer(),
                  SizedBox(
                    height: 50.h,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: 3,
                      itemBuilder: (context, index) {
                        List<int> prices = [
                          (widget.fare * 1.07).truncate(),
                          (widget.fare * 1.10).truncate(),
                          (widget.fare * 1.15).truncate(),
                        ];
                        return Custombutton(
                          width: 200,
                          text: '${prices[index]}PKR',
                          fontSize: 18,
                          ontap: () {
                            savedriverid(
                                context,
                                widget.rideDetails.rideid,
                                widget.duration,
                                widget.distance,
                                prices[index]);
                          },
                        );
                      },
                      separatorBuilder: (context, index) =>
                          addHorizontalspace(width: 6.0),
                      shrinkWrap: true,
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
