// ignore_for_file: library_private_types_in_public_api, prefer_interpolation_to_compose_strings, avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:ridemate/utils/appcolors.dart';
import 'package:ridemate/view/Authentication/components/customappbar.dart';
import 'package:ridemate/widgets/custombutton.dart';
import 'package:ridemate/widgets/customtext.dart';

class ContactUsPage extends StatefulWidget {
  const ContactUsPage({Key? key}) : super(key: key);

  @override
  _ContactUsPageState createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  Future<void> sendEmail() async {
    final String name = _nameController.text;
    final String email = _emailController.text;
    final String message = _messageController.text;
    final String phoneNumber = _phoneNumberController.text;

    // Configure the SMTP server
    String username =
        'muhammadabdurrehman516@gmail.com'; // Replace with your email
    String password = 'dvlpsewyaqgckrck'; // Replace with your email password

    final smtpServer =
        gmail(username, password); // Use the appropriate SMTP server

    final emailMessage = Message()
      ..from = Address(username, 'Easy Rider')
      ..recipients.add('muhammadabdurrehman516@gmail.com')
      ..subject = 'Easy Rider Contact Us'
      ..text =
          'Name: $name\nEmail: $email\nMessage: $message\nPhone: $phoneNumber';

    try {
      final sendReport = await send(emailMessage, smtpServer);
      _showSuccessDialog();
      print('Message sent: ' + sendReport.toString());
    } catch (e) {
      _showFailureDialog(e.toString());
      print('Message not sent. Error: $e');
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 10), // Add some spacing between the icon and text
              Text('Success'),
            ],
          ),
          content: const Text('Email sent successfully'),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showFailureDialog(String error) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.error, color: Colors.red),
              SizedBox(width: 10), // Add some spacing between the icon and text
              Text('Failure'),
            ],
          ),
          content: Text('Failed to send email: $error'),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _validateAndSendEmail() {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _messageController.text.isEmpty ||
        _phoneNumberController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
    } else if (!_isValidEmail(_emailController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address')),
      );
    } else {
      sendEmail();
    }
  }

  bool _isValidEmail(String email) {
    final RegExp regex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return regex.hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customappbar(context,
          title: 'Contact Us', backgroundColor: Colors.transparent),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const CustomText(
                    title: 'Contact us for Ride share',
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    textAlign: TextAlign.center,
                    color: Appcolors.contentPrimary,
                  ),
                  const SizedBox(height: 20),
                  const CustomText(
                    title: 'Address',
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    textAlign: TextAlign.center,
                    color: Appcolors.contentPrimary,
                  ),
                  const SizedBox(height: 10),
                  const CustomText(
                    title: '123 Easy Rider Street,\nCityville, Country 12345',
                    fontSize: 14,
                    textAlign: TextAlign.center,
                    color: Appcolors.neutralgrey,
                  ),
                  const SizedBox(height: 20),
                  const CustomText(
                    title:
                        'Call: +1 (800) 123-4567\nEmail: support@easyrider.com',
                    fontSize: 14,
                    textAlign: TextAlign.center,
                    color: Appcolors.neutralgrey,
                  ),
                  const SizedBox(height: 30),
                  const CustomText(
                    title: 'Send Message',
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    textAlign: TextAlign.center,
                    color: Appcolors.contentPrimary,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _nameController,
                    cursorColor: Appcolors.primaryColor,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Appcolors.primaryColor),
                      ),
                      labelText: 'Enter your name',
                      labelStyle: TextStyle(color: Appcolors.primaryColor),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _emailController,
                    cursorColor: Appcolors.primaryColor,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Appcolors.primaryColor),
                      ),
                      labelText: 'Enter your email',
                      labelStyle: TextStyle(color: Appcolors.primaryColor),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _messageController,
                    cursorColor: Appcolors.primaryColor,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Appcolors.primaryColor),
                      ),
                      hintText: 'Enter your message',
                      hintStyle: TextStyle(color: Appcolors.primaryColor),
                      labelStyle: TextStyle(color: Appcolors.primaryColor),
                    ),
                  ),
                  const SizedBox(height: 20),
                  IntlPhoneField(
                    cursorColor: Appcolors.primaryColor,
                    controller: _phoneNumberController,
                    dropdownTextStyle: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: const InputDecoration(
                      labelStyle: TextStyle(
                        color: Appcolors.primaryColor,
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Appcolors.primaryColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Appcolors.primaryColor),
                      ),
                    ),
                    initialCountryCode: 'PK',
                    onChanged: (phone) {},
                  ),
                  const SizedBox(height: 20),
                  Custombutton(
                    text: 'Submit',
                    fontSize: 16,
                    height: 50,
                    width: double.infinity,
                    fontWeight: FontWeight.w500,
                    borderRadius: 8,
                    ontap: _validateAndSendEmail,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
