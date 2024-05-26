import 'package:flutter/material.dart';
import 'package:ridemate/utils/appcolors.dart';
import 'package:ridemate/widgets/customtext.dart';
import 'package:ridemate/widgets/spacing.dart';

Future<void> errordialogue(BuildContext context) {
  return showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Stack(
            children: [
              Container(
                padding: const EdgeInsets.only(
                  left: 20,
                  top: 60,
                  right: 20,
                  bottom: 20,
                ),
                margin: const EdgeInsets.only(top: 45, left: 35),
                decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.black,
                          offset: Offset(0, 10),
                          blurRadius: 10),
                    ]),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CustomText(
                      title: 'Error',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Appcolors.contentTertiary,
                    ),
                    addVerticalspace(height: 15),
                    const CustomText(
                      title: 'Please fill all the options',
                      fontSize: 15,
                      color: Appcolors.neutralgrey700,
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 35,
                right: 20,
                child: CircleAvatar(
                  backgroundColor: Colors.transparent,
                  radius: 35,
                  child: Image.asset(
                    "assets/error.png",
                    height: 70,
                    width: 70,
                  ),
                ),
              ),
            ],
          ),
        );
      });
}
