// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_otp/email_otp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:provider/provider.dart';
import 'package:ridemate/Providers/completeprofileprovider.dart';
import 'package:ridemate/utils/appcolors.dart';
import 'package:ridemate/view/Authentication/components/authtextform.dart';
import 'package:ridemate/view/Authentication/components/customappbar.dart';
import 'package:ridemate/view/Authentication/components/customrichtext.dart';
import 'package:ridemate/view/Authentication/components/phonefield.dart';
import 'package:ridemate/view/Authentication/view/Completeprofile/components/htmltemp.dart';
import 'package:ridemate/view/Authentication/view/Completeprofile/components/profilepic.dart';
import 'package:ridemate/view/Dialogueboxes/cnicscanner_dialog.dart';
import 'package:ridemate/view/Dialogueboxes/otpalert.dart';
import 'package:ridemate/widgets/spacing.dart';
import '../../../../routing/routing.dart';
import '../../../../widgets/custombutton.dart';
import '../../../Homepage/homepage.dart';

class Completeprofile extends StatelessWidget {
  final void Function()? onPressed1;

  final String phoneno;
  final controller = TextEditingController();
  final formkey = GlobalKey<FormState>();
  final EmailOTP myAuth = EmailOTP();
  Completeprofile({super.key, this.onPressed1, this.phoneno = ''});

  Future<void> verifyemailotp(BuildContext context, String inputOTP) async {
    final prov = Provider.of<Completeprofileprovider>(context, listen: false);
    if (await myAuth.verifyOTP(otp: inputOTP)) {
      prov.cleartextcontroller();
      Navigator.of(context).pop();
      FirebaseFirestore.instance
          .collection('mobileusers')
          .doc(phoneno.codeUnits.join('-'))
          .set(({'Email': controller.text}), SetOptions(merge: true));
      navigateandremove(context, Homepage(phoneno: phoneno));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Wrong otp entered')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customappbar(context, title: 'Profile'),
      backgroundColor: Appcolors.scaffoldbgcolor,
      body: Form(
          key: formkey,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 50),
              child: SizedBox(
                height: MediaQuery.of(context).size.height - 140,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Profilepic(),
                    addVerticalspace(height: 20),
                    Customrichtext(texts: const [
                      'We will scan your cnic for gender confirmation.For any questions please ',
                      'Contact Support',
                    ]),
                    addVerticalspace(height: 20),
                    Consumer<Completeprofileprovider>(
                      builder: (context, cnicprovider, child) => Authtextform(
                        hinttext: 'User Name',
                        readonly: true,
                        controller: cnicprovider.usernameController,
                      ),
                    ),
                    addVerticalspace(height: 20),
                    Consumer<Completeprofileprovider>(
                      builder: (context, cnicprovider, child) => Authtextform(
                        hinttext: 'Gender',
                        readonly: true,
                        controller: cnicprovider.genderController,
                      ),
                    ),
                    addVerticalspace(height: 20),
                    phoneno == ''
                        ? Consumer<Completeprofileprovider>(
                            builder: (context, value, child) => Phonefield(
                              controller: controller,
                              onChanged: (PhoneNumber val) {
                                if (value.btntxt == 'Proceed') {
                                  if (val.number.length == 10) {
                                    value.changebuttonstate(true);
                                  } else {
                                    value.changebuttonstate(false);
                                  }
                                }
                              },
                            ),
                          )
                        : Authtextform(
                            controller: controller,
                            hinttext: 'Enter Email',
                            validator: (p0) {
                              if (p0 == null || p0.isEmpty) {
                                return 'This field cannot be empty';
                              }

                              String pattern =
                                  r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
                              RegExp regex = RegExp(pattern);
                              if (!regex.hasMatch(p0)) {
                                return 'Enter a valid email address';
                              }

                              return null;
                            },
                          ),
                    const Spacer(),
                    Consumer<Completeprofileprovider>(
                      builder: (context, value, child) => Custombutton(
                        text: value.btntxt,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        borderRadius: 8,
                        ontap: value.enabled
                            ? () async {
                                if (value.btntxt == 'Scan') {
                                  cnicscannerdialogue(context, onPressed1)
                                      .then((v) {
                                    if (phoneno == '' &&
                                        controller.text.length < 10) {
                                      value.changebuttonstate(false);
                                    }
                                  });
                                } else {
                                  if (phoneno == '') {
                                    FirebaseFirestore.instance
                                        .collection('googleusers')
                                        .doc(FirebaseAuth
                                            .instance.currentUser!.uid)
                                        .set(
                                            ({
                                              'phoneNumber':
                                                  '92${controller.text}'
                                            }),
                                            SetOptions(merge: true));
                                    navigateandremove(
                                        context, const Homepage());
                                    value.cleartextcontroller();
                                  } else {
                                    if (formkey.currentState!.validate()) {
                                      myAuth.setConfig(
                                        appEmail: "easyrider@gmail.com",
                                        appName: "Easy Rider",
                                        userEmail: controller.text,
                                        otpLength: 4,
                                        otpType: OTPType.digitsOnly,
                                      );
                                      var template = gethtmltemplate();
                                      myAuth.setTemplate(render: template);
                                      if (await myAuth.sendOTP()) {
                                        showotpdialogue(
                                            context, verifyemailotp);
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                                content: Text(
                                                    'Wrong email entered')));
                                      }
                                    }
                                  }
                                }
                              }
                            : null,
                      ),
                    )
                  ],
                ),
              ),
            ),
          )),
    );
  }
}
