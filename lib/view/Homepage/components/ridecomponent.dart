import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:ridemate/Providers/homeprovider.dart';
import 'package:ridemate/utils/appcolors.dart';
import 'package:ridemate/widgets/customtext.dart';

class Ridecomponent extends StatelessWidget {
  final String imagepath;
  final String text;
  final int ind;
  const Ridecomponent(
      {super.key,
      required this.imagepath,
      required this.text,
      required this.ind});

  @override
  Widget build(BuildContext context) {
    return Consumer<Homeprovider>(
      builder: (context, value, child) => GestureDetector(
        onTap: () {
          value.changecategory(ind);
          value.calculatefare();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          width: 105.w,
          decoration: BoxDecoration(
            color: value.selectedindex == ind
                ? Colors.lightBlue.shade100
                : Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                imagepath,
                height: 50.h,
              ),
              CustomText(
                title: text,
                fontSize: 12.sp,
                color: Appcolors.contentTertiary,
              )
            ],
          ),
        ),
      ),
    );
  }
}
