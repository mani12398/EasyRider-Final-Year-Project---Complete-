import 'package:flutter/material.dart';
import 'package:ridemate/routing/routing.dart';
import 'package:ridemate/view/Authentication/view/phoneverifyotp/phoneverifyotp.dart';
import '../../phoneotp/phoneotp.dart';

class Joinviaphoneprovider extends ChangeNotifier {
  bool? ischecked = true;
  bool loading = false;
  bool enabled = false;
  final _phoneotp = PhoneOtp();

  void setcheckstate(bool? value) {
    ischecked = value;
    notifyListeners();
  }

  void changebuttonstate(bool btnstate) {
    enabled = btnstate;
    notifyListeners();
  }

  Future<void> sendOTP(String phoneNo, BuildContext context) async {
    loading = true;
    notifyListeners();
    String response = await _phoneotp.sendOTP(phoneNo);

    if (response == 'Success') {
      loading = false;
      notifyListeners();
      // ignore: use_build_context_synchronously
      navigateToScreen(context, Phoneverifyotp(phoneNo: phoneNo));
    } else {
      loading = false;
      notifyListeners();
    }
  }
}
