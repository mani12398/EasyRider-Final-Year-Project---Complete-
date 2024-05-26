import 'package:flutter/material.dart';
import 'package:ridemate/utils/appcolors.dart';
import 'package:ridemate/view/Authentication/components/customappbar.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customappbar(context,
          title: 'About Us', backgroundColor: Colors.transparent),
      body: const SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Professional Rideshare Platform. Here we will provide you only interesting content, which you will like very much. We\'re dedicated to providing you the best of Rideshare, with a focus on dependability and earning. We\'re working to turn our passion for Rideshare into a booming online website. We hope you enjoy our Rideshare as much as we enjoy offering them to you. We will keep posting more important posts on our website for all of you. Please give your support and love. Professional Rideshare Platform. Here we will provide you only interesting content, which you will like very much. We\'re dedicated to providing you the best of Rideshare, with a focus on dependability and earning. We\'re working to turn our passion for Rideshare into a booming online website. We hope you enjoy our Rideshare as much as we enjoy offering them to you. We will keep posting more important posts on our website for all of you. Please give your support and love.',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5, // Line height
                  letterSpacing: 0.5,
                  color: Appcolors.neutralgrey, // Text color
                ),
                textAlign: TextAlign.justify,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: AboutUsPage(),
  ));
}
