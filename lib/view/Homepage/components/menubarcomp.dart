import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ridemate/widgets/customtext.dart';

import '../../../utils/appcolors.dart';

class Menubarcomp extends StatelessWidget {
  final String text;
  final IconData? icon;
  final void Function()? onTap;
  const Menubarcomp({super.key, required this.text, this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      title: CustomText(
        title: text,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Appcolors.contentSecondary,
      ),
      leading: Icon(
        icon,
        color: Appcolors.contentSecondary,
        size: 18.sp,
      ),
    );
  }
}
