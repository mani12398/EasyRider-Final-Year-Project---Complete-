import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ridemate/utils/appcolors.dart';

class Homecomp1 extends StatelessWidget {
  final IconData? icon;
  const Homecomp1({super.key, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32.w,
      height: 28.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Appcolors.primary100,
      ),
      padding: const EdgeInsets.all(4),
      child: Icon(
        icon,
        size: 24.sp,
        color: Appcolors.contentTertiary,
      ),
    );
  }
}
