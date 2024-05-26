import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ridemate/routing/routing.dart';
import 'package:ridemate/utils/appcolors.dart';
import 'package:ridemate/widgets/customtext.dart';

PreferredSizeWidget customappbar(BuildContext context,
    {String title = '', Color backgroundColor = Colors.transparent}) {
  return AppBar(
    elevation: 0.0,
    backgroundColor: backgroundColor,
    leading: title == 'Profile'
        ? null
        : IconButton(
            onPressed: () => goback(context),
            icon: Icon(
              Icons.arrow_back_ios,
              size: 20.sp,
              color: Appcolors.contentPrimary,
            ),
          ),
    centerTitle: true,
    title: CustomText(
      title: title,
      fontSize: 18,
      fontWeight: FontWeight.w500,
      color: Appcolors.contentPrimary,
    ),
  );
}
