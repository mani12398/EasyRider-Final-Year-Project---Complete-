// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:ridemate/utils/appcolors.dart';
import 'package:ridemate/widgets/custombutton.dart';
import 'package:ridemate/widgets/customtext.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Homepage/homepage.dart';

void showcanceldialogue(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return const CustomAlertDialog1();
    },
  );
}

class CustomAlertDialog1 extends StatelessWidget {
  const CustomAlertDialog1({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      title: const Stack(
        children: [
          Center(
            child: Column(
              children: [
                // Static sad emoji image
                SizedBox(
                  height: 150,
                  width: 150,
                  child: Image(
                    image: AssetImage('assets/sad_emoji.png'),
                  ),
                ),
                SizedBox(height: 10),
                // Bold text
                CustomText(
                  title: 'We are so sad about your cancellation',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  textAlign: TextAlign.center,
                  color: Appcolors.contentPrimary,
                ),
              ],
            ),
          ),
          // Cross icon button
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CustomText(
            title:
                'We will continue to improve our service & satisfy you on the next trip.',
            fontSize: 11,
            textAlign: TextAlign.center,
            color: Appcolors.contentPrimary,
          ),
          const SizedBox(height: 20),
          // Confirm payment button
          Custombutton(
            text: 'Back Home',
            fontSize: 16,
            fontWeight: FontWeight.w500,
            borderRadius: 8,
            ontap: () async {
              final SharedPreferences prefs =
                  await SharedPreferences.getInstance();

              final String phoneNo = prefs.getString('phoneno') ?? '';
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => Homepage(phoneno: phoneNo)),
              );
            },
          ),
        ],
      ),
    );
  }
}
