// ignore_for_file: use_build_context_synchronously, must_be_immutable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:ridemate/services/pushnotificationservice.dart';
import 'package:ridemate/utils/appcolors.dart';
import 'package:ridemate/Methods/drivermethods.dart';
import 'package:ridemate/view/Authentication/view/Driver/bottomnav.dart';
import 'package:ridemate/view/Authentication/view/Driver/driverdrawer.dart';
import 'package:ridemate/view/Authentication/view/Driver/ridecontainer.dart';
import 'package:ridemate/view/Authentication/view/Driver/statictoggleswitch.dart';
import 'package:ridemate/view/Authentication/view/Driver/toggle_button.dart';
import 'package:ridemate/widgets/customtext.dart';
import '../../../../Providers/userdataprovider.dart';
import '../../../../models/ridedetails.dart';

class Driverscreen extends StatefulWidget {
  bool isOnline;
  Driverscreen({super.key, this.isOnline = false});

  @override
  State<Driverscreen> createState() => _DriverscreenState();
}

class _DriverscreenState extends State<Driverscreen> {
  int _selectedIndex = 0;
  double rating = 0;

  @override
  void initState() {
    super.initState();
    getDriverRating(
        Provider.of<Userdataprovider>(context, listen: false).userId);
  }

  Future<void> checkdriverpauseStatus(String id) async {
    final docref =
        FirebaseFirestore.instance.collection('companyprofit').doc(id);
    final docsnap = await docref.get();
    if (docsnap.exists) {
      List data = docsnap.data()!['chargedprofit'] as List;

      int unpaidCount =
          data.where((map) => map['paystatus'] == 'unpaid').length;
      if (unpaidCount < 5) {
        FirebaseFirestore.instance
            .collection('drivers')
            .doc(id)
            .update(({'Status': 'Approved'}));
        showsnackbar('Your application status changed from paused to Approved');
      } else {
        showsnackbar('Your application status is in paused mode');
      }
    }
  }

  Future<void> getDriverRating(String docId) async {
    final docRef = FirebaseFirestore.instance.collection('drivers').doc(docId);
    final docSnapshot = await docRef.get();

    if (docSnapshot.exists) {
      if (docSnapshot.data()!.containsKey('driverating')) {
        rating = docSnapshot['driverating'];
        setState(() {});
        return;
      }
    }
    rating = 4.9;
    setState(() {});
  }

  void showsnackbar(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: CustomText(title: text),
      behavior: SnackBarBehavior.floating,
    ));
  }

  Future<void> savetoken(Map driver, bool isOnline) async {
    if (isOnline) {
      final service = PushNotificationService();
      String? token = await service.getToken();
      final firestore = FirebaseFirestore.instance.collection('drivers');
      if (driver.containsKey('token')) {
        firestore
            .doc(Provider.of<Userdataprovider>(context, listen: false).userId)
            .update({'token': '$token'});
      } else {
        firestore
            .doc(Provider.of<Userdataprovider>(context, listen: false).userId)
            .set({'token': '$token'}, SetOptions(merge: true));
      }
      service.refreshtoken(firestore,
          Provider.of<Userdataprovider>(context, listen: false).userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(65),
          child: AppBar(
            backgroundColor: Appcolors.primaryColor,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 150, top: 15, bottom: 00),
                child: StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('drivers')
                      .doc(Provider.of<Userdataprovider>(context, listen: false)
                          .userId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData ||
                        !snapshot.data!.exists ||
                        snapshot.connectionState == ConnectionState.waiting) {
                      return Statictoggleswitch(
                        onTap: () {
                          showsnackbar('Complete the registration process');
                        },
                      );
                    }
                    final data = snapshot.data!.data() as Map;

                    if (data.containsKey('Status')) {
                      if (data['Status'] == 'Approved') {
                        return ToggleSwitch(
                          initialValue: widget.isOnline,
                          onChanged: (value) {
                            setState(() {
                              widget.isOnline = value;
                            });
                            changedriverstatus(context, value);
                            savetoken(data, value);
                          },
                        );
                      } else if (data['Status'] == 'InReview') {
                        return Statictoggleswitch(
                          onTap: () {
                            showsnackbar('Your application is in review');
                          },
                        );
                      } else if (data['Status'] == 'Paused') {
                        return Statictoggleswitch(
                          onTap: () async {
                            await checkdriverpauseStatus(
                                Provider.of<Userdataprovider>(context,
                                        listen: false)
                                    .userId);
                          },
                        );
                      } else {
                        return Statictoggleswitch(onTap: () {
                          showsnackbar('Complete the registration text');
                        });
                      }
                    } else {
                      return Statictoggleswitch(onTap: () {
                        showsnackbar('Complete the registration text');
                      });
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        drawer: StatefulBuilder(
          builder: (context, setState) {
            return driverdrawer(rating: rating);
          },
        ),
        body: widget.isOnline
            ? StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('RideRequest')
                    .where('Status', isEqualTo: 'Pending')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }

                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  final driverid =
                      Provider.of<Userdataprovider>(context, listen: false)
                          .userId;

                  final filteredDocs = snapshot.data!.docs.where((doc) =>
                      (doc['requestdrivers'] as List).contains(driverid));

                  return ListView.separated(
                    separatorBuilder: (context, index) => const Divider(),
                    itemCount: filteredDocs.length,
                    itemBuilder: (context, index) {
                      final doc = filteredDocs.elementAt(index);

                      RideDetails rideDetails = RideDetails(
                        rideid: doc.id,
                        pickupaddress: doc['pickup_address'],
                        destinationaddress: doc['destination_address'],
                        pickup: LatLng(
                          double.parse(doc['pickup']['latitude'].toString()),
                          double.parse(doc['pickup']['longitude'].toString()),
                        ),
                        dropoff: LatLng(
                          double.parse(doc['dropoff']['latitude'].toString()),
                          double.parse(doc['dropoff']['longitude'].toString()),
                        ),
                        ridername: doc['rider_name'],
                      );

                      return Ridecontainer(
                          rideDetails: rideDetails,
                          fare: int.parse(
                            doc['ridefare'].toString(),
                          ));
                    },
                  );
                },
              )
            : null,
        bottomNavigationBar: BottomNavBar(
          selectedIndex: _selectedIndex,
          onItemTapped: _onItemTapped,
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}
