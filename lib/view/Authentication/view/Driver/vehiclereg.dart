import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:ridemate/Providers/driverregprovider.dart';
import 'package:ridemate/utils/appcolors.dart';
import 'package:ridemate/view/Authentication/components/customappbar.dart';
import 'package:ridemate/view/Dialogueboxes/errordialogue.dart';
import 'package:ridemate/widgets/custombutton.dart';
import 'package:ridemate/widgets/customtext.dart';

import '../../../../Providers/userdataprovider.dart';

class Vehicleregis<T extends Driverregprovider3> extends StatelessWidget {
  final String title;
  const Vehicleregis({super.key, required this.title});

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
                      child: CustomText(
                        title: "Vehicle Registration (Front Side)",
                        color: Colors.black,
                        fontSize: 18,
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
                                    image: value.img1 != null
                                        ? DecorationImage(
                                            image: FileImage(value.img1!),
                                            fit: BoxFit.cover,
                                          )
                                        : null),
                                width: 240.w,
                                height: 140.h,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 30),
                          child: Custombutton(
                              text: 'Add a Photo',
                              height: 40,
                              width: 200,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              borderRadius: 8,
                              ontap: () => myprovider.updateimg1()),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
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
                      child: CustomText(
                        title: "Vehicle Registration (Back Side)",
                        color: Colors.black,
                        fontSize: 18,
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
                                    image: value.img2 != null
                                        ? DecorationImage(
                                            image: FileImage(value.img2!),
                                            fit: BoxFit.cover,
                                          )
                                        : null),
                                width: 240.w,
                                height: 140.h,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 30),
                          child: Custombutton(
                              text: 'Add a Photo',
                              height: 40,
                              width: 200,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              borderRadius: 8,
                              ontap: () => myprovider.updateimg2()),
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

                          value.saveImages(userid, title, context);
                        }
                      }),
                )),
          ],
        ),
      ),
    );
  }
}
