import 'package:flutter/material.dart';

class Onboardingprovider extends ChangeNotifier {
  double progressvalue = 0.7;
  int activepage = 0;

  void setprogressvalue(int index) {
    activepage = index;
    if (index == 1) {
      progressvalue = 0.35;
    } else if (index == 2) {
      progressvalue = 0;
    } else {
      progressvalue = 0.7;
    }
    notifyListeners();
  }
}
