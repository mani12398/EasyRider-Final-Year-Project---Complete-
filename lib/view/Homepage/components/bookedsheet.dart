import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:ridemate/Providers/bookingprovider.dart';
import 'package:ridemate/Providers/homeprovider.dart';
import 'package:ridemate/utils/appcolors.dart';
import 'package:ridemate/view/Cancelride/cancelridepage.dart';
import 'package:ridemate/view/Homepage/components/paycash.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../routing/routing.dart';
import '../../../widgets/custombutton.dart';
import '../../../widgets/customtext.dart';
import '../../messagingscreen/messagingscreen.dart';

Future<void> makePhoneCall(String phoneNumber) async {
  final Uri launchUri = Uri(
    scheme: 'tel',
    path: phoneNumber,
  );
  await launchUrl(launchUri);
}

Widget showbookedsheet(BuildContext context) {
  String rideid = Provider.of<Bookingprovider>(context, listen: false).rideid;
  double rating = Provider.of<Homeprovider>(context, listen: false).rating;
  return DraggableScrollableSheet(
    initialChildSize: 0.4,
    minChildSize: 0.22,
    maxChildSize: 0.5,
    builder: (context, scrollController) {
      return SingleChildScrollView(
        controller: scrollController,
        child: Container(
          color: Colors.white,
          constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.5),
          child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('RideRequest')
                .doc(rideid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final data = snapshot.data;
                final dirmap = data!['rideDuration'];
                if (dirmap['duration'] != null) {
                  final txt = data['Status'] == 'Accepted'
                      ? 'Your driver is coming in ${dirmap['duration']}'
                      : data['Status'] == 'Arrived'
                          ? 'Your driver has Arrived'
                          : 'Going to destination in ${dirmap['duration']}';
                  if (data['Status'] == 'Completed') {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      showPayfaredialogue(
                          context, data['ridefare'], data['driverid']);
                    });
                  }
                  return Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 150.w,
                            height: 5.h,
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.grey[400],
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [],
                            ),
                          ),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [],
                          )
                        ],
                      ),
                      Container(
                        height: 50.h,
                        color: Colors.white,
                        child: Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal:
                                    MediaQuery.of(context).size.width * 0.05,
                              ),
                              child: CustomText(
                                title: txt,
                                fontSize: 15,
                                color: Appcolors.neutralgrey700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                              height: 100.h,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: Appcolors.neutralgrey200,
                                ),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal:
                                    MediaQuery.of(context).size.width * 0.05,
                                vertical: 8.0,
                              ),
                              child: Row(
                                children: [
                                  CustomText(
                                    title:
                                        '${data['carnumber']}${data['carname']}',
                                    fontSize: 13,
                                    color: Appcolors.contentPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  const SizedBox(width: 16.0),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        CustomText(
                                          title: data['drivername'],
                                          fontSize: 15,
                                          color: Appcolors.contentSecondary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        Expanded(
                                          child: Row(
                                            children: [
                                              const Icon(Icons.location_pin,
                                                  size: 16),
                                              const SizedBox(width: 4),
                                              CustomText(
                                                title:
                                                    '${dirmap['distance']}\n(${dirmap['duration']} away)',
                                                fontSize: 7,
                                                color: Appcolors.neutralgrey200,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Row(
                                            children: [
                                              const Icon(Icons.star,
                                                  color: Appcolors.primaryColor,
                                                  size: 16),
                                              const SizedBox(width: 4),
                                              CustomText(
                                                title: '$rating',
                                                fontSize: 7,
                                                color: Appcolors.neutralgrey200,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Spacer(),
                                ],
                              ),
                            ),
                            Container(
                              height: 80.h,
                              color: Colors.white,
                              padding: EdgeInsets.symmetric(
                                horizontal:
                                    MediaQuery.of(context).size.width * 0.1,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const CustomText(
                                    title: 'Cash',
                                    fontSize: 14,
                                    color: Appcolors.neutralgrey700,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  CustomText(
                                    title: '${data['ridefare']}PKR',
                                    fontSize: 22,
                                    color: Appcolors.contentPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              height: 80.h,
                              color: Colors.white,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 320.w,
                                    height: 70.h,
                                    color: Colors.white,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.all(
                                                  MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.02),
                                              child: GestureDetector(
                                                onTap: () async {
                                                  await makePhoneCall(
                                                      '+923348668951');
                                                },
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                      color: Appcolors
                                                          .primaryColor,
                                                      width: 2.0,
                                                    ),
                                                  ),
                                                  child: const CircleAvatar(
                                                    backgroundColor:
                                                        Colors.white,
                                                    foregroundColor:
                                                        Appcolors.primaryColor,
                                                    child: Icon(
                                                      Icons.call,
                                                      color: Appcolors
                                                          .primaryColor,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.all(
                                                MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.02,
                                              ),
                                              child: GestureDetector(
                                                onTap: () => navigateToScreen(
                                                    context,
                                                    ChatScreen(
                                                      title: 'Message Screen',
                                                      isDriver: false,
                                                      rideId: rideid,
                                                    )),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                      color: Appcolors
                                                          .primaryColor,
                                                      width: 2.0,
                                                    ),
                                                  ),
                                                  child: const CircleAvatar(
                                                    backgroundColor:
                                                        Colors.white,
                                                    child: Icon(
                                                      Icons.message,
                                                      color: Appcolors
                                                          .primaryColor,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(
                                            MediaQuery.of(context).size.width *
                                                0.02,
                                          ),
                                          child: Custombutton(
                                            text: 'Cancel Ride',
                                            height: 40.h,
                                            width: 150.w,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            borderRadius: 8,
                                            ontap: data['Status'] == 'Accepted'
                                                ? () {
                                                    navigateToScreen(
                                                        context,
                                                        CancelridePage(
                                                          rideid: rideid,
                                                          afterbooking: true,
                                                          driverid:
                                                              data['driverid'],
                                                        ));
                                                  }
                                                : null,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                } else {
                  return const SizedBox();
                }
              } else {
                return const SizedBox();
              }
            },
          ),
        ),
      );
    },
  );
}
