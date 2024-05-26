import 'package:flutter/material.dart';
import 'package:ridemate/utils/appcolors.dart';
import 'package:ridemate/view/Authentication/components/customappbar.dart';
import 'package:ridemate/widgets/custombutton.dart';

class DeleteAccountPage extends StatelessWidget {
  const DeleteAccountPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customappbar(context,
          title: 'Delete Account', backgroundColor: Colors.transparent),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Are you sure you want to delete your account? Please read how account deletion will affect.',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  letterSpacing: 0.5,
                  color: Appcolors.neutralgrey,
                ),
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 10),
              const Text(
                'Deleting your account removes personal information from our database. Your email becomes permanently reserved and the same email cannot be reused to register a new account.',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  letterSpacing: 0.5,
                  color: Appcolors.neutralgrey,
                ),
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 20),
              Custombutton(
                text: 'Delete',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                borderRadius: 8,
                ontap: () {
                  // Add your account deletion logic here
                  Navigator.of(context).pop();
                },
                buttoncolor: Colors.red,
              ),
              const SizedBox(height: 20), // Add space at the bottom
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: DeleteAccountPage(),
  ));
}
