import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ridemate/routing/routing.dart';
import 'package:ridemate/sidemenupages/contactus.dart';
import 'package:ridemate/sidemenupages/helpandsupport.dart';
import 'package:ridemate/utils/appcolors.dart';
import 'package:ridemate/view/Authentication/view/Driver/goingtoworkas.dart';
import 'package:ridemate/view/Homepage/components/menubarcomp.dart';
import 'package:ridemate/view/Homepage/homepage.dart';
import 'package:ridemate/widgets/custombutton.dart';
import 'package:ridemate/widgets/spacing.dart';

import '../../../../Providers/userdataprovider.dart';
import '../../../../ridesharing/driver/driverscreen.dart';
import '../../../../widgets/customtext.dart';
import '../../../RideHistory/ridehistory11.dart';

// ignore: camel_case_types
class driverdrawer extends StatelessWidget {
  final double rating;
  const driverdrawer({super.key, required this.rating});

  @override
  Widget build(BuildContext context) {
    final usermap = Provider.of<Userdataprovider>(context, listen: false);
    final User? user = FirebaseAuth.instance.currentUser;
    final String? userId = user?.uid;

    return SafeArea(
      child: Drawer(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(80),
                bottomRight: Radius.circular(80))),
        backgroundColor: Appcolors.scaffoldbgcolor,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          children: [
            UserAccountsDrawerHeader(
                accountName: Row(
                  children: [
                    CustomText(
                      title: usermap.userData['Username'],
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Appcolors.contentSecondary,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.star, color: Colors.yellow, size: 20),
                    const SizedBox(width: 4),
                    CustomText(
                      title: '$rating',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Appcolors.contentSecondary,
                    ),
                  ],
                ),
                accountEmail: CustomText(
                  title: FirebaseAuth.instance.currentUser != null
                      ? usermap.userData['Email']
                      : usermap.userData['phoneNumber'],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Appcolors.contentSecondary,
                ),
                decoration:
                    const BoxDecoration(color: Appcolors.scaffoldbgcolor),
                currentAccountPicture: CircleAvatar(
                  radius: 40,
                  backgroundImage: usermap.userData['Profileimage'] == ''
                      ? const AssetImage('assets/personimage.jpg')
                          as ImageProvider
                      : NetworkImage(usermap.userData['Profileimage']),
                )),
            Menubarcomp(
              text: 'Registration',
              icon: Icons.app_registration_outlined,
              onTap: () {
                navigateToScreen(context, const GoingtoWorkAs());
              },
            ),
            const Divider(color: Appcolors.neutralgrey, height: 1),
            Menubarcomp(
              text: 'History',
              icon: Icons.history,
              onTap: () {
                navigateToScreen(
                    context, const RideHistoryPage(isdriver: true));
              },
            ),
            const Divider(color: Appcolors.neutralgrey, height: 1),
            Menubarcomp(
              text: 'Help and Support',
              icon: Icons.help_outline_outlined,
              onTap: () {
                navigateToScreen(context, const HelpSupportPage());
              },
            ),
            const Divider(color: Appcolors.neutralgrey, height: 1),
            Menubarcomp(
              text: 'Contact Us',
              icon: Icons.contact_page_outlined,
              onTap: () {
                navigateToScreen(context, const ContactUsPage());
              },
            ),
            const Divider(color: Appcolors.neutralgrey, height: 1),
            addVerticalspace(height: 20),
            Custombutton(
              buttoncolor: Appcolors.primaryColor,
              ontap: () {
                navigateToScreen(context, const Homepage());
              },
              text: 'Passenger Mode',
            ),
            addVerticalspace(height: 10),
            Custombutton(
              buttoncolor: Appcolors.primaryColor,
              ontap: () {
                if (userId != null) {
                  navigateToScreen(context, DriverScreen1(userId: userId));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('User is not logged in.')),
                  );
                }
              },
              text: 'Ridesharing Mode',
            ),
          ],
        ),
      ),
    );
  }
}
