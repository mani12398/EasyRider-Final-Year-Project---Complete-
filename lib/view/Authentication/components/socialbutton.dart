import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ridemate/utils/appcolors.dart';
import 'package:ridemate/utils/appimages.dart';
import 'package:ridemate/widgets/customtext.dart';

class Socialbutton extends StatelessWidget {
  final String text;
  final bool loading;
  final void Function()? onPressed;
  const Socialbutton(
      {super.key, required this.text, this.loading = false, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54.h,
      width: 362.w,
      child: ElevatedButton.icon(
        icon: loading
            ? const SizedBox()
            : Image.asset(
                AppImages.googlelogo,
                height: 24.h,
                width: 24.w,
              ),
        label: loading
            ? const CupertinoActivityIndicator(radius: 16)
            : CustomText(
                title: text,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Appcolors.primaryColor,
              ),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          side: const BorderSide(color: Appcolors.primaryColor, width: 1),
        ),
      ),
    );
  }
}
