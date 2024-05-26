import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ridemate/Providers/homeprovider.dart';
import 'package:ridemate/Providers/mapprovider.dart';
import 'package:ridemate/view/Homepage/components/rating.dart';

import '../../../utils/appcolors.dart';
import '../../../widgets/custombutton.dart';
import '../../../widgets/customtext.dart';
import '../homepage.dart';

void showPayfaredialogue(BuildContext context, int fare, String driverid) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => Paycash(
      fare: fare,
      driverid: driverid,
    ),
  );
}

void resetapp(BuildContext context) {
  final homeprovider = Provider.of<Homeprovider>(context, listen: false);
  final mapprovider = Provider.of<Mapprovider>(context, listen: false);
  homeprovider.showsheet = false;
  mapprovider.controller = Completer();
  mapprovider.markers.clear();
  mapprovider.polylineset.clear();
  homeprovider.destination = 'Destination';
  homeprovider.faretext = 0;
}

class Paycash extends StatelessWidget {
  final int fare;
  final String driverid;
  const Paycash({super.key, required this.fare, required this.driverid});

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
            title: '$fare PKR',
            fontSize: 24,
            fontWeight: FontWeight.w900,
            textAlign: TextAlign.center,
            color: Appcolors.contentPrimary,
          ),
          const SizedBox(height: 10),
          const CustomText(
            title: 'This is the total trip amount, you have to be pay',
            fontSize: 11,
            textAlign: TextAlign.center,
            color: Appcolors.contentPrimary,
          ),
          const SizedBox(height: 20),
          Custombutton(
            text: 'Pay',
            fontSize: 16,
            fontWeight: FontWeight.w500,
            borderRadius: 8,
            ontap: () async {
              Navigator.of(context).pop();
              resetapp(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const Homepage()),
              );
              showratingdialogue(driverid, context);
            },
          )
        ],
      ),
    );
  }
}
