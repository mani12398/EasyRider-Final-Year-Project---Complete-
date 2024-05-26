import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:ridemate/Methods/mapmethods.dart';
import 'package:ridemate/Providers/userdataprovider.dart';
import 'package:ridemate/models/directiondetails.dart';
import 'package:ridemate/models/ridedetails.dart';
import 'package:ridemate/routing/routing.dart';
import 'package:ridemate/view/Authentication/view/Driver/tripdetail.dart';
import 'package:ridemate/view/Dialogueboxes/progressdialogue.dart';
import 'package:ridemate/widgets/customtext.dart';

import '../../../../widgets/custombutton.dart';

class Ridecontainer extends StatefulWidget {
  final RideDetails rideDetails;
  final int fare;

  const Ridecontainer({
    super.key,
    required this.rideDetails,
    required this.fare,
  });

  @override
  State<Ridecontainer> createState() => _RidecontainerState();
}

void deleteDriverMap(BuildContext context, String id, String driverid) async {
  final docRef = FirebaseFirestore.instance.collection('RideRequest').doc(id);
  final docSnapshot = await docRef.get();

  final data = docSnapshot.data() as Map<String, dynamic>;
  final driversdata = data['driversdata'] as List<dynamic>;
  final driverMap = driversdata.firstWhere(
    (driver) => driver['driverid'] == driverid,
    orElse: () => null,
  );
  if (driverMap != null) {
    await docRef.update({
      'driversdata': FieldValue.arrayRemove([driverMap]),
    });
  }
}

late Timer offerfaretimer;
StreamSubscription? rideRequest;

void savedriverid(BuildContext context, String id, String duration,
    String distance, int dfare) async {
  showProgressDialog(context, 'Offering fare Please wait...');
  final docRef = FirebaseFirestore.instance.collection('RideRequest').doc(id);
  final driverid = Provider.of<Userdataprovider>(context, listen: false).userId;
  List newData = [
    {
      'driverid': driverid,
      'driverdir': {'duration': duration, 'distance': distance},
      'driverfare': dfare,
    }
  ];
  await docRef.update({
    'driversdata': FieldValue.arrayUnion(newData),
  }).then((value) {
    offerfaretimer = Timer(const Duration(seconds: 30), () async {
      deleteDriverMap(context, id, driverid);
      hideProgressDialog(context);
    });
    rideRequest = docRef.snapshots().listen((snapshot) {
      final data = snapshot.data() as Map<String, dynamic>;
      if (data['Status'] == 'Cancelled') {
        offerfaretimer.cancel();
        hideProgressDialog(context);
        rideRequest?.cancel();
      }
    });
  });
}

class _RidecontainerState extends State<Ridecontainer> {
  Future<Directiondetails> getPlacedetail(BuildContext context) async {
    Location location = Location();
    final loc = await location.getLocation();
    final loclatlng = LatLng(loc.latitude!, loc.longitude!);
    final dirdetails =
        await fetchDirectionDetails(loclatlng, widget.rideDetails.pickup);

    return dirdetails;
  }

  @override
  void initState() {
    super.initState();
    getPlacedetail(context);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getPlacedetail(context),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          String distance = snapshot.data!.distancetext;
          String duration = snapshot.data!.durationtext;
          return GestureDetector(
            onTap: () => navigateToScreen(
                context,
                TripDetail(
                  distance: distance,
                  duration: duration,
                  rideDetails: widget.rideDetails,
                  fare: widget.fare,
                )),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.lightGreen,
                borderRadius: BorderRadius.circular(10.0),
              ),
              width: MediaQuery.of(context).size.width,
              height: 200,
              margin: const EdgeInsets.only(left: 10.0, right: 10.0, top: 16.0),
              child: Stack(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 10.0, top: 10.0),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: CircleAvatar(
                        radius: 40,
                        backgroundImage: AssetImage('assets/personimage.jpg'),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 100.0,
                    left: 45.0,
                    child: CustomText(
                      title: widget.rideDetails.ridername,
                      fontSize: 16.0,
                      color: Colors.black,
                    ),
                  ),
                  Positioned(
                    top: 16.0,
                    left: 105.0,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width - 225.0,
                      ),
                      child: CustomText(
                        title: widget.rideDetails.pickupaddress,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 50.0,
                    left: 105.0,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width - 195.0,
                      ),
                      child: CustomText(
                        title: widget.rideDetails.destinationaddress,
                        fontSize: 16.0,
                        color: Colors.black,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 16.0,
                    right: 10.0,
                    child: CustomText(
                      title: '${widget.fare}PKR',
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  Positioned(
                    top: 50.0,
                    right: 10.0,
                    child: CustomText(
                      title: duration,
                      fontSize: 16.0,
                      color: Colors.black,
                    ),
                  ),
                  Positioned(
                    top: 80.0,
                    right: 10.0,
                    child: CustomText(
                      title: distance,
                      fontSize: 16.0,
                      color: Colors.black,
                    ),
                  ),
                  Positioned(
                    bottom: 10.0,
                    left: 0.0,
                    right: 0.0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Custombutton(
                          text: 'Accept',
                          ontap: () {
                            savedriverid(
                              context,
                              widget.rideDetails.rideid,
                              duration,
                              distance,
                              widget.fare,
                            );
                          },
                          fontSize: 16,
                          borderRadius: 8,
                          height: 50,
                          width: 130,
                          fontWeight: FontWeight.bold,
                        ),
                        Custombutton(
                          text: 'Decline',
                          ontap: () {},
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          borderRadius: 8,
                          height: 50,
                          width: 130,
                          fontColor: Colors.red,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }
}
