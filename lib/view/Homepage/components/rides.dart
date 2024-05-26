// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:provider/provider.dart';
import 'package:ridemate/Providers/homeprovider.dart';
import 'package:ridemate/Providers/mapprovider.dart';
import 'package:ridemate/routing/routing.dart';
import 'package:ridemate/utils/appcolors.dart';
import 'package:ridemate/view/Cancelride/cancelridepage.dart';
import 'package:ridemate/view/Homepage/components/userridecontainer.dart';
import 'package:ridemate/widgets/customtext.dart';
import 'package:ridemate/widgets/spacing.dart';

import '../../../services/pushnotificationservice.dart';

void showridebottomsheet(BuildContext context, String rideid) {
  showModalBottomSheet(
    isDismissible: false,
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
    ),
    builder: (context) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.95,
      maxChildSize: 0.95,
      builder: (context, scrollController) => SingleChildScrollView(
        controller: scrollController,
        child: Rides(rideid: rideid),
      ),
    ),
  );
}

class Rides extends StatefulWidget {
  final String rideid;
  const Rides({super.key, required this.rideid});

  @override
  State<Rides> createState() => _RidesState();
}

late StreamSubscription subs;

class _RidesState extends State<Rides> {
  Future<void> sendAcceptmessage(
      String driverid, BuildContext context, int fare) async {
    final doc = await FirebaseFirestore.instance
        .collection('drivers')
        .doc(driverid)
        .get();
    String token = doc['token'];
    double rating = doc.data()!.containsKey('driverating')
        ? doc.data()!['driverating']
        : 4.9;
    PushNotificationService service = PushNotificationService();
    await service.sendNotification(
      token,
      title: "Get Ready",
      bodytxt: "Pick your new Ride",
      rideid: widget.rideid,
    );
    FirebaseFirestore.instance
        .collection('RideRequest')
        .doc(widget.rideid)
        .update({'Status': 'Accepted', 'ridefare': fare});
    final myprovider = Provider.of<Mapprovider>(context, listen: false);
    final homeprovider = Provider.of<Homeprovider>(context, listen: false);
    homeprovider.setemptyaddress();
    Navigator.pop(context);
    savebookdriverinfo(driverid, doc);
    Geofire.stopListener();
    myprovider.resetmarkers();
    await myprovider.bookeddriverstatus(widget.rideid, context);
    final usertoken = await service.getToken();
    await service
        .sendNotification(
          usertoken!,
          title: "Ride booked",
          bodytxt: "Your driver is coming in few mins",
        )
        .then((value) => deleteunuseddata());
    startlistener();
    homeprovider.showbooksheet(rating);
  }

  Future<Map<String, dynamic>> datafromfirestore(String driverid) async {
    final firestore = FirebaseFirestore.instance.collection('drivers');
    final docref = await firestore.doc(driverid).get();
    final map = docref.data() as Map<String, dynamic>;
    return map;
  }

  void deleteunuseddata() {
    final docref =
        FirebaseFirestore.instance.collection('RideRequest').doc(widget.rideid);
    docref.update(({
      'driversdata': FieldValue.delete(),
      'requestdrivers': FieldValue.delete(),
    }));
  }

  void savebookdriverinfo(String driverid, var doc) {
    final docref =
        FirebaseFirestore.instance.collection('RideRequest').doc(widget.rideid);

    docref.set(
        ({
          'driverid': driverid,
          'drivername': doc['Name'],
          'carname': doc['Transportname'],
          'carnumber': doc['Vehicle_Number'],
        }),
        SetOptions(merge: true));
  }

  void startlistener() {
    String checkstatus = 'checkarrive';
    subs = FirebaseFirestore.instance
        .collection('RideRequest')
        .doc(widget.rideid)
        .snapshots()
        .listen((event) async {
      if (event.exists && event.data() != null) {
        var data = event.data()!;
        var status = data['Status'];
        if (checkstatus == 'checkarrive') {
          if (status == 'Arrived') {
            checkstatus = 'checkdest';
            PushNotificationService service = PushNotificationService();
            final token = await service.getToken();
            await service.sendNotification(token!,
                title: 'Your driver has arrived',
                bodytxt: 'Remember to check details');
            subs.cancel();
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.95,
      child: Stack(
        alignment: AlignmentDirectional.topCenter,
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 16,
            right: 16,
            child: TextButton(
              onPressed: () {
                navigateToScreen(
                    context,
                    CancelridePage(
                      rideid: widget.rideid,
                    ));
              },
              child: CustomText(
                title: 'Cancel',
                fontSize: 15,
                color: Appcolors.contentTertiary,
              ),
            ),
          ),
          Positioned(
            top: -12,
            child: Container(
              width: 60,
              height: 7,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Colors.white,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15, right: 15, top: 50),
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('RideRequest')
                  .doc(widget.rideid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final List<dynamic> driversdata =
                      snapshot.data!.data()!['driversdata'];
                  if (driversdata.isEmpty) {
                    return buildLoadingScreen();
                  }

                  return FutureBuilder(
                    future: Future.wait(driversdata.map(
                        (driver) => datafromfirestore(driver['driverid']))),
                    builder: (context, futureSnapshot) {
                      if (futureSnapshot.connectionState ==
                          ConnectionState.done) {
                        final List<Map<String, dynamic>> driverdata =
                            futureSnapshot.data!;
                        return ListView.separated(
                          itemCount: driverdata.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            final durationtxt =
                                driversdata[index]['driverdir']['duration'];
                            final distancetxt =
                                driversdata[index]['driverdir']['distance'];
                            return UserRideContainer(
                              transportName: driverdata[index]['Transportname'],
                              driverName: driverdata[index]['Name'],
                              durationTxt: durationtxt,
                              distanceTxt: distancetxt,
                              onAccept: sendAcceptmessage,
                              driverfare:
                                  driversdata[index]['driverfare'].toString(),
                              driverid: driversdata[index]['driverid'],
                            );
                          },
                          separatorBuilder: (context, index) =>
                              addVerticalspace(height: 7),
                        );
                      } else {
                        return buildLoadingScreen();
                      }
                    },
                  );
                }
                return Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ],
      ),
    );
  }
}

Widget buildLoadingScreen() {
  return Center(
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        CircularProgressIndicator(),
        SizedBox(width: 6),
        CustomText(
          title: 'Searching for drivers...',
          fontSize: 16,
          color: Appcolors.contentTertiary,
        ),
      ],
    ),
  );
}
