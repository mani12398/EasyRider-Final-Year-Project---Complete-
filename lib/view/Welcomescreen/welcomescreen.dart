import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:ridemate/utils/appcolors.dart';
import 'package:ridemate/utils/appimages.dart';
import 'package:ridemate/view/Authentication/components/socialbutton.dart';
import 'package:ridemate/view/Authentication/view/joinviaphone/joinviaphone.dart';
import 'package:ridemate/widgets/custombutton.dart';
import 'package:ridemate/widgets/customtext.dart';
import 'package:ridemate/widgets/spacing.dart';
import '../../Providers/googleauthprovider.dart';
import '../../routing/routing.dart';

class Welcomescreen extends StatelessWidget {
  const Welcomescreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: SingleChildScrollView(
            child: Column(
              children: [
                addVerticalspace(height: 60),
                SvgPicture.asset(
                  AppImages.welcomeimg,
                  height: 276.h,
                  width: double.infinity,
                  fit: BoxFit.fill,
                ),
                addVerticalspace(height: 29),
                const CustomText(
                  title: 'Welcome',
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: Appcolors.contentPrimary,
                ),
                const CustomText(
                  title: 'Have a better sharing experience',
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Appcolors.neutralgrey,
                ),
                addVerticalspace(height: 100),
                Custombutton(
                  text: 'Continue with phone number',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  borderRadius: 8,
                  ontap: () => navigateToScreen(context, Joinviaphone()),
                ),
                addVerticalspace(height: 20),
                Consumer<Googleloginprovider>(
                  builder: (context, value, child) => Socialbutton(
                    text: 'Continue with Google',
                    loading: value.loading,
                    onPressed: () => value.signInWithGoogle(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
