import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomText extends StatelessWidget {
  final String title;
  final double letterSpacing;
  final TextOverflow? overflow;
  final int? maxlines;
  final Color color;
  final TextAlign textAlign;
  final double fontSize;
  final FontWeight fontWeight;

  const CustomText({
    super.key,
    required this.title,
    this.letterSpacing = 0.3,
    this.overflow,
    this.maxlines,
    this.color = Colors.white,
    this.textAlign = TextAlign.start,
    this.fontSize = 12,
    this.fontWeight = FontWeight.normal,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: fontSize.sp,
        fontFamily: 'Poppins',
        fontWeight: fontWeight,
        color: color,
        overflow: overflow,
        letterSpacing: letterSpacing,
        fontStyle: FontStyle.normal,
      ),
      maxLines: maxlines,
      overflow: overflow,
      textAlign: textAlign,
    );
  }
}
