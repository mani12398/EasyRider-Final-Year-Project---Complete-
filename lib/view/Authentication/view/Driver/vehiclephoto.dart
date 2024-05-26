import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:ridemate/Providers/driverregprovider.dart';
import 'package:ridemate/utils/appcolors.dart';
import 'package:ridemate/view/Authentication/components/customappbar.dart';
import 'package:ridemate/widgets/custombutton.dart';

import '../../../../Providers/userdataprovider.dart';
import '../../../Dialogueboxes/errordialogue.dart';

// ignore: camel_case_types
class vehiclephoto<T extends Driverregprovider2> extends StatelessWidget {
  final String title;
  const vehiclephoto({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final myprovider = Provider.of<T>(context, listen: false);
    return Scaffold(
      appBar: customappbar(context,
          title: title, backgroundColor: Appcolors.primaryColor),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: 20,
                left: 10,
                right: 10,
              ),
              child: Container(
                height: 360,
                width: 450,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 3,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(
                        top: 15,
                      ),
                      child: Text(
                        "Vehicle Photo",
                        style: TextStyle(
                          // Making text bold
                          color: Colors.black, // Changing text color
                          fontSize: 18, // Changing text size
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(
                            top: 50,
                          ),
                        ),
                        Center(
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(10.0),
                              child: Consumer<T>(
                                builder: (context, value, child) => Container(
                                  decoration: BoxDecoration(
                                      color: Appcolors.neutralgrey200,
                                      image: value.image != null
                                          ? DecorationImage(
                                              image: FileImage(value.image!),
                                              fit: BoxFit.cover,
                                            )
                                          : null),
                                  width: 240.w,
                                  height: 140.h,
                                ),
                              )),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 40),
                          child: Custombutton(
                              text: 'Add a Photo',
                              height: 40,
                              width: 200,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              borderRadius: 8,
                              ontap: () => myprovider.updateimage()),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
                padding: const EdgeInsets.only(top: 50, bottom: 50),
                child: Consumer<T>(
                  builder: (context, value, child) => Custombutton(
                      text: 'Done',
                      loading: value.loading,
                      height: 60,
                      width: 300,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      borderRadius: 8,
                      ontap: () {
                        if (value.checkisempty()) {
                          errordialogue(context);
                        } else {
                          String userid = Provider.of<Userdataprovider>(context,
                                  listen: false)
                              .userId;

                          value.saveImage(userid, title, context);
                        }
                      }),
                )),
          ],
        ),
      ),
    );
  }
}
