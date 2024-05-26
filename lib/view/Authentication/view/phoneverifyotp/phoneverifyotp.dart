import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import 'package:ridemate/Providers/verifyotpprovider.dart';
import 'package:ridemate/utils/appcolors.dart';
import 'package:ridemate/view/Authentication/components/customappbar.dart';
import 'package:ridemate/view/Authentication/components/customrichtext.dart';
import 'package:ridemate/widgets/custombutton.dart';
import 'package:ridemate/widgets/customtext.dart';
import 'package:ridemate/widgets/spacing.dart';

class Phoneverifyotp extends StatelessWidget {
  final String phoneNo;
  Phoneverifyotp({super.key, required this.phoneNo});

  final otpController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final myprovider = Provider.of<Verifyotpprovider>(context, listen: false);
    final formkey = GlobalKey<FormState>();
    final defaultPinTheme = PinTheme(
      width: 50,
      height: 48,
      textStyle: const TextStyle(
          fontSize: 24,
          color: Color.fromRGBO(65, 65, 65, 1),
          fontWeight: FontWeight.w600),
      decoration: BoxDecoration(
        color: const Color(0xffffffff),
        borderRadius: BorderRadius.circular(7.1),
        border: Border.all(color: const Color.fromRGBO(208, 208, 208, 1)),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      borderRadius: BorderRadius.circular(7.1),
      border: Border.all(color: const Color.fromRGBO(246, 205, 86, 1)),
    );

    final errorPinTheme = defaultPinTheme.copyDecorationWith(
      borderRadius: BorderRadius.circular(7.1),
      border: Border.all(color: Appcolors.errorColor),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        color: const Color.fromRGBO(255, 253, 231, 1),
        borderRadius: BorderRadius.circular(7.1),
        border: Border.all(color: const Color.fromRGBO(246, 205, 86, 1)),
      ),
    );
    return Scaffold(
      appBar: customappbar(context),
      body: Form(
          key: formkey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                addVerticalspace(height: 15),
                const CustomText(
                  title: 'Phone verification',
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: Appcolors.contentPrimary,
                ),
                addVerticalspace(height: 12),
                const CustomText(
                  title: 'Enter your OTP code',
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Appcolors.neutralgrey,
                ),
                addVerticalspace(height: 40),
                Pinput(
                  controller: otpController,
                  cursor: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 9),
                      width: 22,
                      height: 1,
                      color: const Color.fromRGBO(246, 205, 86, 1),
                    ),
                  ),
                  defaultPinTheme: defaultPinTheme,
                  errorPinTheme: errorPinTheme,
                  length: 5,
                  separatorBuilder: (index) => addHorizontalspace(width: 8),
                  validator: (value) {
                    return myprovider.errormessage == ''
                        ? null
                        : myprovider.errormessage;
                  },
                  onChanged: (value) {
                    value.length == 5
                        ? myprovider.changebuttonstate(true)
                        : myprovider.changebuttonstate(false);
                  },
                  focusedPinTheme: focusedPinTheme,
                  submittedPinTheme: submittedPinTheme,
                ),
                addVerticalspace(height: 20),
                Customrichtext(
                  texts: const [
                    "Didn't receive code?",
                    ' Resend again',
                  ],
                ),
                const Spacer(),
                Consumer<Verifyotpprovider>(
                  builder: (context, verifyprovider, child) => Custombutton(
                    text: 'Verify ',
                    loading: verifyprovider.loading,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    borderRadius: 8,
                    ontap: verifyprovider.enabled
                        ? () {
                            verifyprovider
                                .verifyOTP(phoneNo, otpController.text)
                                .then((value) {
                              if (formkey.currentState!.validate()) {
                                verifyprovider.checkuserexistance(
                                    context, phoneNo);
                              }
                            });
                          }
                        : null,
                  ),
                ),
              ],
            ),
          )),
    );
  }
}
