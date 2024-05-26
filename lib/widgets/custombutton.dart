import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ridemate/utils/appcolors.dart';
import 'package:ridemate/widgets/customtext.dart';

class Custombutton extends StatelessWidget {
  final double height;
  final double width;
  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final Color fontColor;
  final Color buttoncolor;
  final Color bordercolor;
  final double borderRadius;
  final void Function()? ontap;
  final bool haveborder;
  final IconData icon;
  final bool loading;

  const Custombutton({
    super.key,
    this.height = 54,
    this.width = 362,
    this.text = '',
    this.fontSize = 15,
    this.borderRadius = 20,
    this.buttoncolor = Appcolors.primaryColor,
    this.fontColor = Colors.white,
    this.bordercolor = Colors.white,
    this.fontWeight = FontWeight.normal,
    this.ontap,
    this.haveborder = false,
    this.icon = Icons.arrow_forward,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height.h,
      width: width.w,
      child: ElevatedButton(
        onPressed: ontap,
        style: ElevatedButton.styleFrom(
          backgroundColor: haveborder ? Colors.white : buttoncolor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius.r),
          ),
          side: haveborder ? BorderSide(color: bordercolor, width: 1) : null,
        ),
        child: text == ''
            ? Icon(
                icon,
                size: 25.sp,
                color: Appcolors.contentTertiary,
              )
            : loading
                ? const CupertinoActivityIndicator(radius: 16)
                : CustomText(
                    title: text,
                    fontSize: fontSize,
                    color: fontColor,
                    fontWeight: fontWeight,
                  ),
      ),
    );
  }
}
