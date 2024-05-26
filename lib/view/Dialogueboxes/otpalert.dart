// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:ridemate/utils/appcolors.dart';
import 'package:ridemate/widgets/custombutton.dart';
import 'package:ridemate/widgets/customtext.dart';

String? validateOTP(String? value) {
  if (value == null || value.length != 4) {
    return 'Please enter a valid 4-digit OTP';
  }

  return null;
}

void showotpdialogue(BuildContext context,
    Future<void> Function(BuildContext, String) verifyemailotp) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return OTPAlertDialog(verifyemailotp: verifyemailotp);
    },
  );
}

class OTPAlertDialog extends StatefulWidget {
  final Future<void> Function(BuildContext, String) verifyemailotp;

  const OTPAlertDialog({Key? key, required this.verifyemailotp})
      : super(key: key);

  @override
  _OTPAlertDialogState createState() => _OTPAlertDialogState();
}

class _OTPAlertDialogState extends State<OTPAlertDialog> {
  late TextEditingController _otpController;

  @override
  void initState() {
    super.initState();
    _otpController = TextEditingController();
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      title: const Center(
        child: CustomText(
          title: 'Enter OTP',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          textAlign: TextAlign.center,
          color: Appcolors.contentPrimary,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Pinput(
            controller: _otpController,
            cursor: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: const EdgeInsets.only(bottom: 9),
                width: 22,
                height: 1,
                color: const Color.fromRGBO(246, 205, 86, 1),
              ),
            ),
            length: 4,
            separatorBuilder: (index) => const SizedBox(width: 8),
            validator: validateOTP,
            defaultPinTheme: defaultPinTheme,
            focusedPinTheme: focusedPinTheme,
            errorPinTheme: errorPinTheme,
            submittedPinTheme: submittedPinTheme,
          ),
          const SizedBox(height: 20),
          Custombutton(
            text: 'Verify OTP',
            fontSize: 16,
            fontWeight: FontWeight.w500,
            borderRadius: 8,
            ontap: () async {
              final otp = _otpController.text;
              if (validateOTP(otp) == null) {
                await widget.verifyemailotp(context, otp);
              }
            },
          ),
        ],
      ),
    );
  }
}
