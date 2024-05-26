import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:ridemate/routing/routing.dart';
import 'package:ridemate/utils/appcolors.dart';
import 'package:ridemate/utils/appconstants.dart';
import 'package:ridemate/utils/appimages.dart';
import 'package:ridemate/view/Onboarding/components/onboardingcomponent.dart';
import 'package:ridemate/view/Welcomescreen/welcomescreen.dart';
import 'package:ridemate/widgets/custombutton.dart';
import 'package:ridemate/widgets/customtext.dart';
import 'package:ridemate/widgets/spacing.dart';

import '../../Providers/onboardingprovider.dart';

class Onboarding extends StatelessWidget {
  final PageController _pageController = PageController(initialPage: 0);

  Onboarding({super.key});

  @override
  Widget build(BuildContext context) {
    final onboardprovider =
        Provider.of<Onboardingprovider>(context, listen: false);
    return Scaffold(
      backgroundColor: Appcolors.scaffoldbgcolor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            children: [
              addVerticalspace(height: 12),
              Align(
                alignment: Alignment.topRight,
                child: InkWell(
                  onTap: () => navigateToScreen(context, const Welcomescreen()),
                  child: const CustomText(
                    title: 'Skip',
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Appcolors.contentSecondary,
                  ),
                ),
              ),
              addVerticalspace(height: 40),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.46,
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (value) {
                    onboardprovider.setprogressvalue(value);
                  },
                  children: [
                    Onboardingcomponent(
                        image: AppImages.onboardimg1,
                        title: 'Anywhere you are'),
                    Onboardingcomponent(
                        image: AppImages.onboardimg2, title: 'At anytime'),
                    Onboardingcomponent(
                        image: AppImages.onboardimg3, title: 'Book your car'),
                  ],
                ),
              ),
              addVerticalspace(height: 10),
              const CustomText(
                title: Appconstants.onboardtxt,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xffA0A0A0),
                textAlign: TextAlign.center,
              ),
              addVerticalspace(height: 85),
              SizedBox(
                height: 80.h,
                width: 86.w,
                child: Stack(
                  children: [
                    SizedBox(
                        width: 86.w,
                        height: 80.h,
                        child: Consumer<Onboardingprovider>(
                          builder: (context, onboardingprovider, child) {
                            return CircularProgressIndicator(
                              strokeWidth: 3,
                              value: onboardingprovider.progressvalue,
                              backgroundColor: Appcolors.primaryColor,
                              valueColor: const AlwaysStoppedAnimation(
                                  Color(0xffFFF1B1)),
                            );
                          },
                        )),
                    Positioned.fill(
                      child: Center(child: Consumer<Onboardingprovider>(
                        builder: (context, onboardprovider, child) {
                          return Custombutton(
                            text: onboardprovider.activepage == 2 ? 'Go' : '',
                            fontColor: Appcolors.contentTertiary,
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            height: 65,
                            width: 70,
                            borderRadius: 50,
                            ontap: onboardprovider.activepage == 2
                                ? () => navigateToScreen(
                                    context, const Welcomescreen())
                                : () {
                                    _pageController.animateToPage(
                                      onboardprovider.activepage + 1,
                                      duration:
                                          const Duration(microseconds: 300),
                                      curve: Curves.bounceIn,
                                    );
                                  },
                          );
                        },
                      )),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
