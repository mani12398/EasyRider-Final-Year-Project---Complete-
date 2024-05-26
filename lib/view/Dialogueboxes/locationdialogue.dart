import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ridemate/utils/appcolors.dart';
import 'package:ridemate/widgets/custombutton.dart';
import 'package:ridemate/widgets/customtext.dart';
import 'package:ridemate/widgets/spacing.dart';

Future<void> locationdialogue(BuildContext context) {
  return showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        backgroundColor: Appcolors.scaffoldbgcolor,
        insetPadding: EdgeInsets.zero,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        child: Container(
          padding: const EdgeInsets.all(15).w,
          width: 340.w,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                addVerticalspace(height: 10.h),
                Image.asset(
                  'assets/location.gif',
                  width: 110.w,
                  height: 110.h,
                  fit: BoxFit.cover,
                ),
                addVerticalspace(height: 32.h),
                CustomText(
                  title: 'Enable your location',
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w500,
                  color: Appcolors.contentPrimary,
                ),
                addVerticalspace(height: 10.h),
                CustomText(
                  title:
                      'Choose your location to start find the\nrequest around you',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Appcolors.neutralgrey,
                  textAlign: TextAlign.center,
                ),
                addVerticalspace(height: 30.h),
                Custombutton(
                  borderRadius: 8.r,
                  text: 'Use my location',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                ),
                addVerticalspace(height: 18.h),
                Custombutton(
                  borderRadius: 8.r,
                  text: 'Skip for now',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  fontColor: Appcolors.contentDisbaled,
                  haveborder: true,
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
