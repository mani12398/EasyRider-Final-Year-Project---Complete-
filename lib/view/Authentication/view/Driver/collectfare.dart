// ignore_for_file: use_build_context_synchronously, must_be_immutable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ridemate/Methods/drivermethods.dart';
import 'package:ridemate/Providers/userdataprovider.dart';
import 'package:ridemate/models/ridedetails.dart';
import 'package:ridemate/routing/routing.dart';
import 'package:ridemate/utils/appcolors.dart';
import 'package:ridemate/view/Authentication/view/Driver/driverscreen.dart';
import 'package:ridemate/widgets/custombutton.dart';
import 'package:ridemate/widgets/customtext.dart';

void showcollectfaredialogue(BuildContext context, RideDetails rideDetails) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => CollectfareDialog(
      rideDetails: rideDetails,
    ),
  );
}

class CollectfareDialog extends StatelessWidget {
  final RideDetails rideDetails;
  bool makeonline = true;
  CollectfareDialog({super.key, required this.rideDetails});

  Future<void> savedriverearnings(BuildContext context) async {
    final driverid =
        Provider.of<Userdataprovider>(context, listen: false).userId;
    int driverearn = (rideDetails.ridefare * 0.95).truncate();
    int compprof = rideDetails.ridefare - driverearn;
    await addcompanyprofit(driverid, compprof);

    final docref =
        FirebaseFirestore.instance.collection('drivers').doc(driverid);
    final docsnap = await docref.get();
    final docdata = docsnap.data();
    if (docdata!.containsKey('driverearnings')) {
      int previousearnings = docdata['driverearnings'];
      int newearning = previousearnings + driverearn;
      docref.update(({'driverearnings': newearning}));
    } else {
      docref.set(({'driverearnings': driverearn}), SetOptions(merge: true));
    }
  }

  Future<void> addcompanyprofit(String id, int profit) async {
    Map newdata = {
      'rideid': rideDetails.rideid,
      'paystatus': 'unpaid',
      'companyprofit': profit,
    };
    final docref =
        FirebaseFirestore.instance.collection('companyprofit').doc(id);
    final docsnap = await docref.get();
    if (docsnap.exists) {
      docref
          .update(({
        'chargedprofit': FieldValue.arrayUnion([newdata]),
      }))
          .then((value) {
        List data = docsnap.data()!['chargedprofit'] as List;

        int unpaidCount =
            data.where((map) => map['paystatus'] == 'unpaid').length;
        if (unpaidCount > 4) {
          FirebaseFirestore.instance
              .collection('drivers')
              .doc(id)
              .update(({'Status': 'Paused'}));
          makeonline = false;
        }
      });
    } else {
      docref.set(({
        'chargedprofit': [newdata],
      }));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      title: const Center(
        child: CustomText(
          title: 'Trip Fare',
          fontSize: 20,
          fontWeight: FontWeight.w100,
          textAlign: TextAlign.center,
          color: Appcolors.contentPrimary,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Divider(color: Colors.grey, thickness: 0.5),
          const SizedBox(height: 10),
          CustomText(
            title: '${rideDetails.ridefare}PKR',
            fontSize: 24,
            fontWeight: FontWeight.w900,
            textAlign: TextAlign.center,
            color: Appcolors.contentPrimary,
          ),
          const SizedBox(height: 10),
          const CustomText(
            title:
                'This is the total trip amount, it has been charged to the rider',
            fontSize: 11,
            textAlign: TextAlign.center,
            color: Appcolors.contentPrimary,
          ),
          const SizedBox(height: 20),
          Custombutton(
            text: 'Confirm Payment',
            fontSize: 16,
            fontWeight: FontWeight.w500,
            borderRadius: 8,
            ontap: () async {
              await savedriverearnings(context).then((value) {
                Navigator.of(context).pop();
                if (makeonline == true) {
                  resumehometablivelocation(context);
                }

                navigateandremove(context, Driverscreen(isOnline: makeonline));
              });
            },
          )
        ],
      ),
    );
  }
}
