// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:ridemate/ridesharing/driver/addride.dart';
import 'package:ridemate/ridesharing/driver/driverridehistory.dart';
import 'package:ridemate/ridesharing/driver/notificationscreen.dart';
import 'package:ridemate/services/pushnotificationservice.dart';
import 'package:ridemate/utils/appcolors.dart';
import 'package:ridemate/view/Authentication/view/Driver/driverscreen.dart';
//import 'package:ridemate/view/Authentication/view/Driver/goingtoworkas.dart';
//import 'package:ridemate/view/Homepage/components/menubarcomp.dart';
import 'package:ridemate/widgets/custombutton.dart';
import 'package:ridemate/widgets/customtext.dart';
import '../../../Providers/userdataprovider.dart';

class DriverScreen1 extends StatefulWidget {
  final String userId;

  const DriverScreen1({Key? key, required this.userId})
      : super(
            key: key); // Fix the constructor to properly accept a key parameter

  @override
  State<DriverScreen1> createState() => _DriverScreen1State();
}

class _DriverScreen1State extends State<DriverScreen1> {
  GoogleMapController? mapController;
  Position? currentLocation;

  @override
  void initState() {
    super.initState();
    _getLocation();
    saveToken();
  }

  void _getLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        currentLocation = position;
        // Update the location in Firestore
        // _updateLocationInFirestore(position);
      });
    } catch (e) {
      //print("Error getting location: $e");
    }
  }

  Future<void> saveToken() async {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    try {
      final service = PushNotificationService();
      final token = await service.getToken();

      if (token != null && token.isNotEmpty) {
        final firestore = FirebaseFirestore.instance.collection('drivers');
        await firestore.doc(userId).update({'token': token});
        print('Token saved successfully');
      } else {
        print('Error: Token is null or empty');
      }
    } catch (error) {
      print('Error saving token: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Appcolors
            .primaryColor, // Set the background color of the app bar to transparent
      ),
      drawer: _buildDrawer(), // Add the Drawer here
      body: Stack(
        children: [
          _buildMapWidget(),
          _buildBottomContainer(context),
        ],
      ),
    );
  }

  Widget _buildMapWidget() {
    if (currentLocation == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // Create a custom marker icon
    BitmapDescriptor customMarkerIcon =
        BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow);

    return GoogleMap(
      onMapCreated: (GoogleMapController controller) {
        mapController = controller;
      },
      initialCameraPosition: CameraPosition(
        target: LatLng(
          currentLocation?.latitude ?? 0,
          currentLocation?.longitude ?? 0,
        ),
        zoom: 15,
      ),
      myLocationEnabled: true,
      markers: <Marker>{
        Marker(
          markerId: const MarkerId("current_location"),
          position: LatLng(
            currentLocation?.latitude ?? 0,
            currentLocation?.longitude ?? 0,
          ),
          icon: customMarkerIcon, // Set the custom marker icon
          infoWindow: const InfoWindow(
            title: 'Custom Location',
            snippet: 'Additional info here',
          ),
        ),
      },
      mapType: MapType.normal,
      mapToolbarEnabled: false,
      zoomControlsEnabled: false,
      myLocationButtonEnabled: false,
    );
  }

  Widget _buildBottomContainer(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 321,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(143, 206, 176, 5).withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 3,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            RichText(
              textAlign: TextAlign.center,
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: 'Driver ',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFFCC00), // Custom color FFCC00
                      shadows: [
                        Shadow(
                          blurRadius: 1,
                          color: Colors.grey,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                  TextSpan(
                    text: 'SCREEN',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Pacifico', // Example of a different font
                      color: Colors.black87,
                      shadows: [
                        Shadow(
                          blurRadius: 3,
                          color: Colors.grey,
                          offset: Offset(1, 1),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            _buildButtonRow(
              iconPath: 'assets/image5.png',
              buttonText: 'Add Ride',
              buttonInfo: 'Add your weekly rides',
            ),
            Divider(
              color: Colors.grey[400],
              thickness: 1,
              height: 10,
            ),
            _buildButtonRow(
              iconPath: 'assets/image5.png',
              buttonText: 'Rides',
              buttonInfo: 'View you rides details',
            ),
            Divider(
              color: Colors.grey[400],
              thickness: 1,
              height: 10,
            ),
            _buildButtonRow(
              iconPath: 'assets/image5.png',
              buttonText: 'Accept',
              buttonInfo: 'View request for bookings',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButtonRow({
    required String iconPath,
    required String buttonText,
    required String buttonInfo,
  }) {
    return Row(
      children: [
        const SizedBox(width: 5),
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddRideScreen(userId: widget.userId),
              ),
            );
          },
          icon: Image.asset(
            iconPath,
            width: 35,
            height: 42,
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              buttonInfo,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
            TextButton(
              onPressed: () {
                if (buttonText == 'Add Ride') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          AddRideScreen(userId: widget.userId),
                    ),
                  );
                } else if (buttonText == 'Rides') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          DriverRideHistoryScreen(userId: widget.userId),
                    ),
                  );
                } else if (buttonText == 'Accept') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          NotificationsScreen(driverid: widget.userId),
                    ),
                  );
                }
              },
              child: Text(
                buttonText,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 17,
                  fontFamily: 'Actor',
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDrawer() {
    final usermap = Provider.of<Userdataprovider>(context, listen: false);
    return SafeArea(
      child: Drawer(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(80),
            bottomRight: Radius.circular(80),
          ),
        ),
        backgroundColor: Appcolors.scaffoldbgcolor,
        child: Consumer<Userdataprovider>(
          builder: (context, userProvider, child) {
            final userData = userProvider.userData;
            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              children: [
                UserAccountsDrawerHeader(
                    accountName: CustomText(
                      title: userData['Username'] ?? 'Username',
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Appcolors.contentSecondary,
                    ),
                    accountEmail: CustomText(
                      title: userData['phoneNumber'] ??
                          userData['Email'] ??
                          'PhoneNumber or Email',
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
                const SizedBox(height: 20),
                Custombutton(
                  buttoncolor: Appcolors.primaryColor,
                  ontap: () {
                    navigateToScreen(context, Driverscreen());
                  },
                  text: 'Driver Mode',
                ),
                
              ],
            );
          },
        ),
      ),
    );
  }

  void navigateToScreen(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Driverscreen()),
    );
  }
}
