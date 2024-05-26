import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:ridemate/Providers/completeprofileprovider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../phoneotp/phoneotp.dart';
import '../../routing/routing.dart';
import '../../view/Authentication/view/Completeprofile/completeprofile.dart';
import '../../view/Homepage/homepage.dart';

class Verifyotpprovider extends ChangeNotifier {
  bool loading = false;
  final _phoneotp = PhoneOtp();
  String errormessage = '';
  bool enabled = false;
  bool haveuser = false;

  Future<void> verifyOTP(String phoneNo, String otp) async {
    loading = true;
    notifyListeners();
    String response = await _phoneotp.verifyOTP(phoneNo, otp);
    if (response == 'Success') {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLogin', true);
      await prefs.setString('phoneno', phoneNo);
      await addUserToFirestore(phoneNo);
      loading = false;
      errormessage = '';
      notifyListeners();
    } else {
      loading = false;
      errormessage = response;
      notifyListeners();
    }
  }

  Future<void> addUserToFirestore(String mobileNo) async {
    CollectionReference mobileUsers =
        FirebaseFirestore.instance.collection('mobileusers');

    String asciiPhoneNumber = mobileNo.codeUnits.join('-');

    bool documentExists =
        await mobileUsers.doc(asciiPhoneNumber).get().then((doc) => doc.exists);

    if (!documentExists) {
      await mobileUsers.doc(asciiPhoneNumber).set({
        'phoneNumber': mobileNo,
        'role': 'User',
      });
    } else {
      haveuser = true;
    }
  }

  void changebuttonstate(bool btnstate) {
    enabled = btnstate;
    notifyListeners();
  }

  void profilefunction(
      BuildContext context, String mobileNo, ImageSource imageSource) {
    final cnicprovider =
        Provider.of<Completeprofileprovider>(context, listen: false);
    CollectionReference mobileUsers =
        FirebaseFirestore.instance.collection('mobileusers');

    String asciiPhoneNumber = mobileNo.codeUnits.join('-');
    Navigator.pop(context);
    cnicprovider.scanCnic(imageSource, context, mobileUsers, asciiPhoneNumber);
  }

  void checkuserexistance(BuildContext context, String phoneNo) {
    if (haveuser) {
      navigateandremove(context, Homepage(phoneno: phoneNo));
    } else {
      navigateToScreen(
        context,
        Completeprofile(
          onPressed1: () {
            profilefunction(context, phoneNo, ImageSource.camera);
          },
          phoneno: phoneNo,
        ),
      );
    }
  }
}
