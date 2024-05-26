// ignore_for_file: use_build_context_synchronously
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:ridemate/Providers/verifyotpprovider.dart';
import 'package:ridemate/routing/routing.dart';
import 'package:ridemate/utils/appcolors.dart';
import 'package:ridemate/utils/appimages.dart';
import 'package:ridemate/view/Authentication/view/Completeprofile/completeprofile.dart';
import 'package:ridemate/view/Onboarding/onboarding.dart';
import 'package:ridemate/widgets/customtext.dart';
import 'package:ridemate/widgets/spacing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Providers/completeprofileprovider.dart';
import '../Homepage/homepage.dart';

class Splashscreen extends StatelessWidget {
  const Splashscreen({super.key});

  Future<void> checkloginstatus(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool islogin = prefs.getBool('isLogin') ?? false;
    final String phoneNo = prefs.getString('phoneno') ?? '';

    if (FirebaseAuth.instance.currentUser != null) {
      final users = FirebaseFirestore.instance.collection('googleusers');
      final document =
          await users.doc(FirebaseAuth.instance.currentUser!.uid).get();
      final data = document.data() as Map<String, dynamic>;
      if (data.containsKey('Gender') && data.containsKey('Username')) {
        navigateToScreen(context, const Homepage());
      } else {
        final cnicprovider =
            Provider.of<Completeprofileprovider>(context, listen: false);
        navigateToScreen(
          context,
          Completeprofile(
            onPressed1: () {
              Navigator.pop(context);
              cnicprovider.scanCnic(ImageSource.camera, context, users,
                  FirebaseAuth.instance.currentUser!.uid);
            },
          ),
        );
      }
    } else if (islogin) {
      final verifyprovider =
          Provider.of<Verifyotpprovider>(context, listen: false);
      final users = FirebaseFirestore.instance.collection('mobileusers');
      String asciiPhoneNumber = phoneNo.codeUnits.join('-');
      DocumentSnapshot document = await users.doc(asciiPhoneNumber).get();
      final data = document.data() as Map<String, dynamic>;
      if (data.containsKey('Gender') && data.containsKey('Username')) {
        navigateandremove(context, Homepage(phoneno: phoneNo));
      } else {
        navigateToScreen(
          context,
          Completeprofile(
            onPressed1: () {
              verifyprovider.profilefunction(
                  context, phoneNo, ImageSource.camera);
            },
            phoneno: phoneNo,
          ),
        );
      }
    } else {
      navigateandremove(context, Onboarding());
    }
  }

  @override
  Widget build(BuildContext context) {
    Timer(const Duration(seconds: 2), (() => checkloginstatus(context)));
    return Scaffold(
      backgroundColor: Appcolors.splashbgColor,
      body: Center(
        child: Column(
          children: [
            addVerticalspace(height: 240),
            Container(
              height: 120,
              width: 125.76,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(34), color: Colors.white),
              child: Image.asset(
                AppImages.splashlogo1,
                width: 71.w,
                height: 68.h,
              ),
            ),
            addVerticalspace(height: 15),
            const CustomText(
              title: 'Easy Rider',
              fontSize: 45,
              fontWeight: FontWeight.w800,
            ),
            addVerticalspace(height: 15),
            Image.asset(
              AppImages.splashlogo2,
              height: 100.h,
              width: 100.w,
              color: Appcolors.scaffoldbgcolor,
            ),
          ],
        ),
      ),
    );
  }
}
