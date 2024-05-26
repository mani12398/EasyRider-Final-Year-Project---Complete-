import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ridemate/utils/appcolors.dart';
import 'package:ridemate/utils/appconstants.dart';
import 'package:ridemate/utils/appimages.dart';
import 'package:ridemate/widgets/customtext.dart';
import 'package:ridemate/widgets/spacing.dart';

Future<void> congratdialogue(BuildContext context) {
  return showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        backgroundColor: Appcolors.scaffoldbgcolor,
        insetPadding: EdgeInsets.zero,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        child: Container(
          padding:
              const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 50).w,
          width: 340.w,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.close,
                        size: 24.sp,
                        color: Appcolors.contentTertiary,
                      )),
                ),
                addVerticalspace(height: 40.h),
                Image.asset(
                  'assets/success.gif',
                  width: 124.w,
                  height: 124.h,
                  fit: BoxFit.cover,
                ),
                addVerticalspace(height: 23.h),
                CustomText(
                  title: 'Congratulations ',
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w500,
                  color: Appcolors.contentPrimary,
                ),
                addVerticalspace(height: 10.h),
                CustomText(
                  title: Appconstants.congrattext,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: Appcolors.neutralgrey,
                  textAlign: TextAlign.center,
                ),
                addVerticalspace(height: 6.h),
                Image.asset(
                  AppImages.splashlogo2,
                  width: 100.w,
                  height: 56.h,
                  fit: BoxFit.cover,
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
