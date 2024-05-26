import 'package:flutter/material.dart';
import 'package:ridemate/utils/appcolors.dart';
import 'package:ridemate/widgets/customtext.dart';
import 'package:ridemate/widgets/spacing.dart';

Future<void> cnicscannerdialogue(
  BuildContext context,
  void Function()? onPressed1,
) {
  return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: Dialog(
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
                  margin: const EdgeInsets.only(top: 45),
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
                        title: 'Cnic Scanner',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Appcolors.contentTertiary,
                      ),
                      addVerticalspace(height: 15),
                      const CustomText(
                        title: 'Open Camera to scan',
                        fontSize: 15,
                        color: Appcolors.neutralgrey700,
                      ),
                      addVerticalspace(height: 22),
                      Center(
                        child: TextButton(
                          onPressed: onPressed1,
                          child: const CustomText(
                            title: 'CAMERA',
                            fontSize: 18,
                            color: Appcolors.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 20,
                  right: 20,
                  child: CircleAvatar(
                    backgroundColor: Colors.transparent,
                    radius: 45,
                    child: Image.asset("assets/person_icon.png"),
                  ),
                ),
              ],
            ),
          ),
        );
      });
}
