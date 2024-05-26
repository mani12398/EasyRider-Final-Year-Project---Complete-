import 'package:flutter/material.dart';
import 'package:ridemate/utils/appcolors.dart';
import 'package:ridemate/view/Authentication/components/customappbar.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customappbar(context,
          title: 'Help & Support', backgroundColor: Colors.transparent),
      body: const SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Help & Support',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Appcolors.neutralgrey700,
                ),
              ),
              SizedBox(height: 20), // Add some spacing
              Text(
                'At Easy Rider, we\'re not just about providing a ride; we\'re about delivering an experience that exceeds your expectations every time you travel with us. We understand that life can be hectic, and getting from point A to point B should be the least of your worries. That\'s why we\'ve made it our mission to offer a seamless, convenient, and reliable ride-booking service that you can count on. Whether you\'re commuting to work, running errands, or exploring a new city, EasyRider is here to make your journey smooth and stress-free. With our user-friendly app and a fleet of well-maintained vehicles driven by professional and courteous drivers, we prioritize your comfort, safety, and satisfaction above all else. So why stress about transportation when you can ride with EasyRider? Sit back, relax, and enjoy the journey with us!',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5, // Line height
                  letterSpacing: 0.5,
                  color: Appcolors.neutralgrey, // Text color
                ),
                textAlign: TextAlign.justify,
              ),
              SizedBox(height: 20), // Add some spacing
              Text(
                'If you need any help or support, feel free to reach out to our customer service team. Our support representatives are available 24/7 to assist you with any inquiries or concerns you may have. You can contact us via email at support@easyrider.com or by phone at +1 (800) 123-4567.',
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
    home: HelpSupportPage(),
  ));
}
