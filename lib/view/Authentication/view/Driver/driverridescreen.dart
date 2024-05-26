// ignore_for_file: use_build_context_synchronously, must_be_immutable

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:ridemate/Methods/drivermethods.dart';
import 'package:ridemate/Providers/driverrideprovider.dart';
import 'package:ridemate/models/ridedetails.dart';
import 'package:ridemate/utils/appcolors.dart';
import 'package:ridemate/view/Authentication/view/Driver/collectfare.dart';
import 'package:ridemate/view/Authentication/view/Driver/driverscreen.dart';
import 'package:ridemate/view/Dialogueboxes/progressdialogue.dart';
import 'package:ridemate/widgets/custombutton.dart';
import 'package:ridemate/widgets/customtext.dart';
import 'package:ridemate/widgets/spacing.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../routing/routing.dart';
import '../../../messagingscreen/messagingscreen.dart';

StreamSubscription? cancelsubs;

void startcancelsubs(BuildContext context, String rideid) {
  cancelsubs = FirebaseFirestore.instance
      .collection('RideRequest')
      .doc(rideid)
      .snapshots()
      .listen((event) {
    if (event['Status'] == 'Cancelled') {
      cancelsubs?.cancel();
      Provider.of<DriverRideProivder>(context, listen: false)
          .ridestreamsubscription
          .cancel();
      resumehometablivelocation(context);
      navigateandremove(context, Driverscreen(isOnline: true));
    }
  });
}

class DriverRideScreen extends StatelessWidget {
  final RideDetails rideDetails;
  DriverRideScreen({super.key, required this.rideDetails});
  final CameraPosition _kGooglePlex =
      const CameraPosition(target: LatLng(33.6941, 72.9734), zoom: 14.4746);
  final Completer<GoogleMapController> mapcontroller = Completer();

  Future<void> makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }

  void updateridestatus(String status) {
    FirebaseFirestore.instance
        .collection('RideRequest')
        .doc(rideDetails.rideid)
        .update({'Status': status});
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Stack(
          children: [
            Consumer<DriverRideProivder>(
              builder: (context, value, child) => GoogleMap(
                padding: EdgeInsets.only(bottom: 300.h),
                initialCameraPosition: _kGooglePlex,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                onMapCreated: (controller) {
                  mapcontroller.complete(controller);
                  value.newgooglemapcontroller = controller;
                  value.setcurrentPosition().then((v) {
                    value.savecurrentLocation(rideDetails.rideid);
                    var currentLatLng = LatLng(value.currentPosition.latitude!,
                        value.currentPosition.longitude!);
                    var pickupLatLng = rideDetails.pickup;
                    value.getPlaceDirection(currentLatLng, pickupLatLng);
                    value.animatedrivercar(rideDetails);
                  });
                },
                markers: Set<Marker>.of(value.markersSet),
                polylines: value.polylineset,
              ),
            ),
            DraggableScrollableSheet(
              initialChildSize: 0.4,
              minChildSize: 0.22,
              maxChildSize: 0.5,
              builder: (context, scrollController) => SingleChildScrollView(
                controller: scrollController,
                child: Container(
                  constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.5),
                  padding: const EdgeInsets.only(
                      bottom: 20, top: 15, left: 15, right: 10),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    color: Colors.white,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 150.w,
                          height: 5.h,
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                      Consumer<DriverRideProivder>(
                        builder: (context, value, child) => CustomText(
                          title: value.durationText,
                          textAlign: TextAlign.center,
                          color: Appcolors.contentTertiary,
                          fontSize: 13,
                        ),
                      ),
                      addVerticalspace(height: 10),
                      ListTile(
                        leading: const Icon(Icons.person),
                        title: CustomText(
                          title: rideDetails.ridername,
                          color: Appcolors.contentPrimary,
                        ),
                        onTap: () {},
                      ),
                      ListTile(
                        leading: const Icon(Icons.location_on),
                        title: CustomText(
                          title: rideDetails.pickupaddress,
                          color: Appcolors.contentPrimary,
                        ),
                        onTap: () {},
                      ),
                      ListTile(
                        leading: const Icon(Icons.location_on),
                        title: CustomText(
                          title: rideDetails.destinationaddress,
                          color: Appcolors.contentPrimary,
                        ),
                        onTap: () {},
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                            onTap: () async {
                              await makePhoneCall('+923348668951');
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Appcolors.primaryColor,
                                  width: 2.0,
                                ),
                              ),
                              child: const CircleAvatar(
                                backgroundColor: Colors.white,
                                foregroundColor: Appcolors.primaryColor,
                                child: Icon(
                                  Icons.call,
                                  color: Appcolors.primaryColor,
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => navigateToScreen(
                                context,
                                ChatScreen(
                                  title: 'Message Screen',
                                  isDriver: true,
                                  rideId: rideDetails.rideid,
                                )),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Appcolors.primaryColor,
                                  width: 2.0,
                                ),
                              ),
                              child: const CircleAvatar(
                                backgroundColor: Colors.white,
                                child: Icon(
                                  Icons.message,
                                  color: Appcolors.primaryColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Consumer<DriverRideProivder>(
                        builder: (context, value, child) => Custombutton(
                          text: value.btntxt,
                          ontap: () async {
                            if (value.btntxt == 'Arrived') {
                              value.changebtntxt('Start trip');
                              updateridestatus('Arrived');
                              showProgressDialog(context, 'Please wait...');
                              await value.getPlaceDirection(
                                  rideDetails.pickup, rideDetails.dropoff);
                              hideProgressDialog(context);
                            } else if (value.btntxt == 'Start trip') {
                              value.changebtntxt('End trip');
                              updateridestatus('Ride Start');
                              value.initcounter();
                            } else if (value.btntxt == 'End trip') {
                              updateridestatus('Completed');
                              value.endtrip();
                              showcollectfaredialogue(context, rideDetails);
                            }
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
