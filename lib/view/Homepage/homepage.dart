import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:ridemate/Providers/bookingprovider.dart';
import 'package:ridemate/Providers/homeprovider.dart';
import 'package:ridemate/Providers/mapprovider.dart';
import 'package:ridemate/Providers/userdataprovider.dart';
import 'package:ridemate/services/pushnotificationservice.dart';
import 'package:ridemate/utils/appcolors.dart';
import 'package:ridemate/view/Homepage/components/bookedsheet.dart';
import 'package:ridemate/view/Homepage/components/faredialogue.dart';
import 'package:ridemate/view/Homepage/components/homecomp1.dart';
import 'package:ridemate/view/Homepage/components/ridecomponent.dart';
import 'package:ridemate/view/Homepage/components/search.dart';
import 'package:ridemate/view/Homepage/components/sidemenubar.dart';
import 'package:ridemate/widgets/custombutton.dart';
import 'package:ridemate/widgets/customtext.dart';
import 'package:image/image.dart' as images;
import 'package:ridemate/widgets/spacing.dart';

class Homepage extends StatefulWidget {
  final String? phoneno;
  const Homepage({super.key, this.phoneno});

  @override
  State<Homepage> createState() => _HomepageState();
}

final ridemap = [
  {'image': 'assets/ridemini.png', 'text': 'RideMini'},
  {'image': 'assets/ridego.png', 'text': 'RideGo'},
  {'image': 'assets/ridebusiness.png', 'text': 'RideGo+'},
  {'image': 'assets/bike.png', 'text': 'Bike'},
];

Future<Uint8List> makeReceiptImage() async {
  // Load avatar image
  ByteData imageData = await rootBundle.load('assets/personimage.jpg');
  var bytes = Uint8List.view(imageData.buffer);
  var avatarImage = images.decodeImage(bytes);

  // Load marker image
  imageData = await rootBundle.load('assets/ma.png');
  bytes = Uint8List.view(imageData.buffer);
  var markerImage = images.decodeImage(bytes);

  // Resize the marker image to the desired dimensions
  markerImage = images.copyResize(markerImage!, width: 96, height: 122);

  // Resize the avatar image to fit inside the marker image
  avatarImage = images.copyResize(avatarImage!,
      width: markerImage.width ~/ 1.1, height: markerImage.height ~/ 1.4);

  var radius = 40;
  int originX = avatarImage.width ~/ 2, originY = avatarImage.height ~/ 2;

  // Draw the avatar image cropped as a circle inside the marker image
  for (int y = -radius; y <= radius; y++) {
    for (int x = -radius; x <= radius; x++) {
      if (originX + x + 8 >= 0 &&
          originX + x < avatarImage.width &&
          originY + y + 10 >= 0 &&
          originY + y < avatarImage.height &&
          x * x + y * y <= radius * radius) {
        markerImage.setPixel(originX + x + 8, originY + y + 10,
            avatarImage.getPixelSafe(originX + x, originY + y));
      }
    }
  }

  return images.encodePng(markerImage);
}

class _HomepageState extends State<Homepage> {
  final _scaffoldState = GlobalKey<ScaffoldState>();
  bool isChecked = false;
  final CameraPosition _kGooglePlex =
      const CameraPosition(target: LatLng(33.6941, 72.9734), zoom: 14.4746);

  @override
  void initState() {
    super.initState();
    Provider.of<Userdataprovider>(context, listen: false)
        .loaduserdata(widget.phoneno);
    initializeservice();
  }

  String getgender() {
    return Provider.of<Userdataprovider>(context, listen: false)
        .userData['Gender'];
  }

  void initializeservice() async {
    final service = PushNotificationService();
    await service.init(context);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        key: _scaffoldState,
        drawer: const Sidemenubar(),
        body: Stack(
          children: [
            Consumer<Mapprovider>(
              builder: (context, value, child) => GoogleMap(
                padding: EdgeInsets.only(bottom: 330.h),
                initialCameraPosition: _kGooglePlex,
                zoomControlsEnabled: false,
                onMapCreated: (mapcontroller) {
                  value.controller.complete(mapcontroller);
                  value.newgooglemapcontroller = mapcontroller;
                  value.setposition(context);
                },
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                markers: Set<Marker>.of(value.markers),
                polylines: value.polylineset,
              ),
            ),
            Positioned(
              left: 15,
              right: 15,
              top: 37,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                      onTap: () => _scaffoldState.currentState!.openDrawer(),
                      child: const Homecomp1(icon: Icons.menu)),
                  const Homecomp1(icon: Icons.notifications),
                ],
              ),
            ),
            Consumer<Homeprovider>(
              builder: (context, value, child) => value.address == '' &&
                      value.showsheet == false
                  ? const SizedBox()
                  : value.address == '' && value.showsheet
                      ? showbookedsheet(context)
                      : Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Container(
                            height: 430.h,
                            padding: const EdgeInsets.only(
                                bottom: 20, top: 15, left: 15, right: 10),
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(30),
                                topRight: Radius.circular(30),
                              ),
                              color: Colors.white,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 85.h,
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    itemBuilder: (context, index) =>
                                        Ridecomponent(
                                            imagepath: ridemap[index]['image']
                                                .toString(),
                                            ind: index,
                                            text: ridemap[index]['text']
                                                .toString()),
                                    separatorBuilder: (context, index) =>
                                        addHorizontalspace(width: 4),
                                    itemCount: 4,
                                  ),
                                ),
                                addVerticalspace(height: 6),
                                ListTile(
                                    leading: const Icon(Icons.location_on),
                                    title: gettext(value.address),
                                    onTap: () => showsearchbottomsheet(context,
                                        ispickup: true)),
                                const Divider(color: Appcolors.contentDisbaled),
                                ListTile(
                                  leading: const Icon(Icons.location_on),
                                  title: gettext(value.destination),
                                  onTap: () => showsearchbottomsheet(context),
                                ),
                                const Divider(color: Appcolors.contentDisbaled),
                                ListTile(
                                  leading: const Icon(Icons.money),
                                  title: gettext(value.faretext == 0
                                      ? 'Fare'
                                      : '${value.faretext}PKR'),
                                  onTap: () {
                                    if (value.faretext != 0) {
                                      showFareDialog(context, value.actualfare);
                                    }
                                  },
                                ),
                                const Divider(color: Appcolors.contentDisbaled),
                                StatefulBuilder(
                                  builder: (context, setState) {
                                    return CheckboxListTile(
                                      title: const Text(
                                        'Gender Preference',
                                        style: TextStyle(
                                            color: Appcolors.contentDisbaled,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      value: isChecked,
                                      onChanged: (bool? value) {
                                        setState(
                                          () {
                                            isChecked = value ?? false;
                                          },
                                        );
                                      },
                                      controlAffinity:
                                          ListTileControlAffinity.leading,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                        side: const BorderSide(
                                            color: Appcolors.primaryColor),
                                      ),
                                    );
                                  },
                                ),
                                Consumer<Bookingprovider>(
                                  builder: (context, bookingProvider, child) =>
                                      Custombutton(
                                    text: 'Request Ride',
                                    loading: bookingProvider.loading,
                                    ontap: bookingProvider.enabledbutton
                                        ? () async {
                                            bookingProvider
                                                .saveRideRequest(context);
                                            await bookingProvider
                                                .sendRideRequesttoNearestDriver(
                                                    getgender(),
                                                    context,
                                                    isChecked);
                                          }
                                        : null,
                                    fontSize: 16,
                                    borderRadius: 8,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget gettext(String txt) {
  return CustomText(
    title: txt,
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: Appcolors.contentDisbaled,
  );
}
