import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ridemate/utils/appcolors.dart';
import 'package:ridemate/widgets/customtext.dart';
import 'package:ridemate/widgets/spacing.dart';

// ignore: must_be_immutable
class Onboardingcomponent extends StatelessWidget {
  String image;
  String title;
  Onboardingcomponent({super.key, required this.image, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SvgPicture.asset(
          image,
          height: 208.h,
          width: 373.w,
        ),
        addVerticalspace(height: 40),
        CustomText(
          title: title,
          fontSize: 24,
          fontWeight: FontWeight.w500,
          color: Appcolors.contentPrimary,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
