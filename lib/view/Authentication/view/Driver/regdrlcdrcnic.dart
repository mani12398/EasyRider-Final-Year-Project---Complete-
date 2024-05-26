import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:ridemate/Providers/driverregprovider.dart';
import 'package:ridemate/Providers/userdataprovider.dart';
import 'package:ridemate/routing/routing.dart';
import 'package:ridemate/utils/appcolors.dart';
import 'package:ridemate/view/Authentication/components/customappbar.dart';
import 'package:ridemate/view/Authentication/components/customtextfield.dart';
import 'package:ridemate/view/Authentication/view/Driver/overlaycamera.dart';
import 'package:ridemate/view/Dialogueboxes/errordialogue.dart';
import 'package:ridemate/widgets/custombutton.dart';
import 'package:ridemate/widgets/customtext.dart';

// ignore: camel_case_types
class Regdrlcdrcnic<T extends Driverregprovider1> extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();
  final String title;
  Regdrlcdrcnic({super.key, required this.title});

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
                height: 350,
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
                    Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: CustomText(
                        title: title == 'Driver Licence'
                            ? "Driver Licence (Front Side)"
                            : "CNIC (Front Side)",
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
                                    image: value.frontimage != ''
                                        ? DecorationImage(
                                            image: FileImage(
                                                File(value.frontimage)),
                                            fit: BoxFit.fitWidth,
                                            alignment: FractionalOffset.center,
                                          )
                                        : null,
                                  ),
                                  width: 200.w,
                                  height: 100.h,
                                ),
                              )),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 50),
                          child: Custombutton(
                              text: 'Add a Photo',
                              height: 40,
                              width: 200,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              borderRadius: 8,
                              ontap: () => navigateToScreen(
                                  context,
                                  OverlayCamera(
                                    onpressed: myprovider.updatefrontpath,
                                    type: title,
                                  ))),
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
                height: 350,
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
                    Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: CustomText(
                        title: title == 'Driver Licence'
                            ? "Driver Licence (Back Side)"
                            : "CNIC (Back Side)",
                        color: Colors.black,
                        fontSize: 18,
                      ),
                    ),
                    Column(
                      children: [
                        const Padding(padding: EdgeInsets.only(top: 50)),
                        Center(
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(10.0),
                              child: Consumer<T>(
                                builder: (context, value, child) => Container(
                                  decoration: BoxDecoration(
                                    color: Appcolors.neutralgrey200,
                                    image: value.backimage != ''
                                        ? DecorationImage(
                                            image: FileImage(
                                                File(value.backimage)),
                                            fit: BoxFit.fitWidth,
                                            alignment: FractionalOffset.center,
                                          )
                                        : null,
                                  ),
                                  width: 200.w,
                                  height: 100.h,
                                ),
                              )),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 50),
                          child: Custombutton(
                              text: 'Add a Photo',
                              height: 40,
                              width: 200,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              borderRadius: 8,
                              ontap: () => navigateToScreen(
                                  context,
                                  OverlayCamera(
                                    onpressed: myprovider.updatebackpath,
                                    type: title,
                                  ))),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            title == 'Driver Licence'
                ? const SizedBox()
                : Padding(
                    padding: const EdgeInsets.only(
                      top: 20,
                      left: 10,
                      right: 10,
                    ),
                    child: Container(
                      height: 150,
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
                              title: "CNIC",
                              color: Colors.black,
                              fontSize: 18,
                            ),
                          ),
                          Column(
                            children: [
                              const Padding(padding: EdgeInsets.only(top: 0)),
                              Padding(
                                padding: const EdgeInsets.only(top: 20),
                                child: CustomTextField(
                                  controller: _controller,
                                  hintText: 'Enter CNIC',
                                  isNumericOnly: true,
                                ),
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
                        String userid = Provider.of<Userdataprovider>(context,
                                listen: false)
                            .userId;
                        if (value.checkisempty()) {
                          errordialogue(context);
                        } else if (title == 'CNIC') {
                          if (_controller.text == '' ||
                              _controller.text.length < 13) {
                            errordialogue(context);
                          } else {
                            value.saveImages(
                                userid, title, _controller.text, context);
                          }
                        } else {
                          value.saveImages(
                              userid, title, _controller.text, context);
                        }
                      }),
                )),
          ],
        ),
      ),
    );
  }
}
