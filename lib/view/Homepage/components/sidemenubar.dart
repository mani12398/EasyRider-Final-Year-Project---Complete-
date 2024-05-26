import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:ridemate/Providers/userdataprovider.dart';
import 'package:ridemate/routing/routing.dart';
import 'package:ridemate/sidemenupages/aboutus.dart';
import 'package:ridemate/sidemenupages/contactus.dart';
import 'package:ridemate/sidemenupages/helpandsupport.dart';
import 'package:ridemate/sidemenupages/privacy.dart';
import 'package:ridemate/utils/appcolors.dart';
import 'package:ridemate/view/Authentication/view/Driver/driverscreen.dart';
import 'package:ridemate/view/Homepage/components/menubarcomp.dart';
import 'package:ridemate/view/RideHistory/ridehistory11.dart';
import 'package:ridemate/view/Welcomescreen/welcomescreen.dart';
import 'package:ridemate/widgets/custombutton.dart';
import 'package:ridemate/widgets/customtext.dart';
import 'package:ridemate/widgets/spacing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../ridesharing/user/userscreen.dart';

class Sidemenubar extends StatelessWidget {
  const Sidemenubar({super.key});

  @override
  Widget build(BuildContext context) {
    final usermap = Provider.of<Userdataprovider>(context, listen: false);
    final User? user = FirebaseAuth.instance.currentUser;
    final String? userId = user?.uid;

    Future<void> logout() async {
      if (FirebaseAuth.instance.currentUser != null) {
        await GoogleSignIn().disconnect();
        FirebaseAuth.instance.signOut();
      } else {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLogin', false);
      }
      // ignore: use_build_context_synchronously
      navigateandremove(context, const Welcomescreen());
    }

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
                accountName: CustomText(
                  title: usermap.userData['Username'],
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Appcolors.contentSecondary,
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
              text: 'History',
              icon: Icons.history,
              onTap: () {
                navigateToScreen(context, const RideHistoryPage());
              },
            ),
            const Divider(color: Appcolors.neutralgrey, height: 1),
            Menubarcomp(
              text: 'About Us',
              icon: Icons.info_outline,
              onTap: () {
                navigateToScreen(context, const AboutUsPage());
              },
            ),
            const Divider(color: Appcolors.neutralgrey, height: 1),
            Menubarcomp(
              text: 'Privacy & Policy',
              icon: Icons.privacy_tip,
              onTap: () {
                navigateToScreen(context, const PrivacyPolicyPage());
              },
            ),
            const Divider(color: Appcolors.neutralgrey, height: 1),
            Menubarcomp(
              text: 'Contact Us',
              icon: Icons.contact_page,
              onTap: () {
                navigateToScreen(context, const ContactUsPage());
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
                text: 'Logout', icon: Icons.logout_outlined, onTap: logout),
            const Divider(color: Appcolors.neutralgrey, height: 1),
            addVerticalspace(height: 20),
            Custombutton(
              buttoncolor: Appcolors.primaryColor,
              ontap: () {
                navigateToScreen(context, Driverscreen());
              },
              text: 'Driver Mode',
            ),
            addVerticalspace(height: 10),
            Custombutton(
              buttoncolor: Appcolors.primaryColor,
              ontap: () {
                if (userId != null) {
                  navigateToScreen(context, Userscreen(userId: userId));
                } else {
                  // Handle the case when userId is null
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
