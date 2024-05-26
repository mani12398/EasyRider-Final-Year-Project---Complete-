import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:ridemate/utils/appcolors.dart';
import 'package:ridemate/view/Authentication/components/hinttextstyle.dart';

class Phonefield extends StatelessWidget {
  final TextEditingController controller;
  final Function(PhoneNumber) onChanged;
  const Phonefield(
      {super.key, required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return IntlPhoneField(
      controller: controller,
      cursorColor: Appcolors.primaryColor,
      dropdownTextStyle: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w500,
        color: const Color(0xff262626),
      ),
      dropdownIconPosition: IconPosition.trailing,
      decoration: InputDecoration(
        labelText: 'Your mobile number',
        labelStyle: gethintstyle(),
        border: const OutlineInputBorder(
            borderSide: BorderSide(color: Appcolors.neutralgrey200)),
        focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Appcolors.primaryColor)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      initialCountryCode: 'PK',
      onChanged: onChanged,
    );
  }
}
