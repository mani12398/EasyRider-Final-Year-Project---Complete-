import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ridemate/utils/appcolors.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? hintText;
  final bool isNumericOnly;

  const CustomTextField({
    Key? key,
    required this.controller,
    this.hintText,
    this.isNumericOnly = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0), // Adjust outer border radius
        border: Border.all(
          color: Appcolors.primaryColor, // Change the color as needed
          width: 1.0,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0), // Adjust inner border radius
        child: TextField(
          controller: controller,
          keyboardType: isNumericOnly
              ? const TextInputType.numberWithOptions(
                  decimal: false, signed: false)
              : TextInputType.text,
          inputFormatters: [
            if (isNumericOnly)
              LengthLimitingTextInputFormatter(
                  13), // Apply length limit for digits only
            if (isNumericOnly) FilteringTextInputFormatter.digitsOnly,
          ],
          style:
              const TextStyle(color: Colors.black), // Set text color to white
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle:
                const TextStyle(color: Colors.black), // Add hint text color
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 12.0, vertical: 16.0), // Adjust padding as needed
            border: InputBorder.none, // Remove default border
            filled: true, // Set TextField to fill its container
            fillColor: Colors.white, // Set background color to white
          ),
          cursorColor: Appcolors.primaryColor, // Set cursor color
          onChanged: (value) {
            if (isNumericOnly && value.length > 13) {
              controller.text = value.substring(0, 13);
              controller.selection = TextSelection.fromPosition(
                  TextPosition(offset: controller.text.length));
            }
          },
        ),
      ),
    );
  }
}
