import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Widget addVerticalspace({double height = 0.0}) {
  return SizedBox(
    height: height.h,
  );
}

Widget addHorizontalspace({double width = 0.0}) {
  return SizedBox(
    width: width.h,
  );
}
