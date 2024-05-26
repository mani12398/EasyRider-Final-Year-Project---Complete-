import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as Geolocator;
import 'package:location/location.dart';
import 'package:ridemate/ridesharing/user/historyuser.dart';
import 'package:ridemate/routing/routing.dart';
import 'package:ridemate/services/pushnotificationservice.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ridemate/Providers/userdataprovider.dart';
import 'package:ridemate/ridesharing/user/booking.dart';
import 'package:ridemate/ridesharing/user/sendreq.dart';
import 'package:ridemate/utils/appcolors.dart';
import 'package:ridemate/view/Authentication/view/Driver/goingtoworkas.dart';
import 'package:ridemate/view/Homepage/components/menubarcomp.dart';
import 'package:ridemate/view/Homepage/homepage.dart';
import 'package:ridemate/widgets/custombutton.dart';
import 'package:ridemate/widgets/customtext.dart';
import 'package:provider/provider.dart';

class Userscreen extends StatefulWidget {
  final String userId;

  const Userscreen({Key? key, required this.userId}) : super(key: key);

  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<Userscreen> {
  GoogleMapController? mapController;
  LocationData? currentLocation;

  @override
  void initState() {
    super.initState();
    _getLocation();
    savetoken();
  }

  void _getLocation() async {
    try {
      Geolocator.Position position =
          await Geolocator.Geolocator.getCurrentPosition(
        desiredAccuracy: Geolocator.LocationAccuracy.high,
      );
      setState(() {
        currentLocation = LocationData.fromMap({
          'latitude': position.latitude,
          'longitude': position.longitude,
        });
      });
    } catch (e) {
      //print("Error getting location: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Appcolors.primaryColor,
      ),
      drawer: _buildDrawer(),
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

    BitmapDescriptor customMarkerIcon = BitmapDescriptor.defaultMarkerWithHue(
      BitmapDescriptor.hueYellow,
    );

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
          icon: customMarkerIcon,
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

  Future<void> savetoken() async {
    final useridd = FirebaseAuth.instance.currentUser?.uid ?? '';

    final service = PushNotificationService();
    String? token = await service.getToken();
    if (token != null && token.isNotEmpty) {
      final firestore = FirebaseFirestore.instance.collection('users-token');
      firestore.doc(useridd).set({
        'token': token,
        'userid': useridd,
      }).then((_) {
        //print('Token saved successfully');
      }).catchError((error) {
        //print('Error saving token: $error');
      });
    } else {
      //print('Error: Token is null or empty');
    }
  }

  Widget _buildBottomContainer(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 251,
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
                    text: 'USER ',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFFCC00),
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
                      fontFamily: 'Pacifico',
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
              iconPath: 'assets/location.gif',
              buttonText: 'Book Ride',
              buttonInfo: 'Book your weekly rides',
            ),
            Divider(
              color: Colors.grey[400],
              thickness: 1,
              height: 10,
            ),
            _buildButtonRow(
              iconPath: 'assets/image5.png',
              buttonText: 'Bookings',
              buttonInfo: 'View your bookings',
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
                builder: (context) => booking(userId: widget.userId),
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
                if (buttonText == 'Book Ride') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Sendrequest(userId: widget.userId),
                    ),
                  );
                } else if (buttonText == 'Bookings') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => booking(userId: widget.userId),
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
                  ),
                ),
              Menubarcomp(
  text: 'History',
  icon: Icons.history,
  onTap: () {
    navigateToScreen(context, UserRideHistoryScreen(userId: widget.userId));
  },
),
const SizedBox(height: 20),
Custombutton(
  buttoncolor: Appcolors.primaryColor,
  ontap: () {
    // Navigate to the Homepage
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Homepage()),
    );
  },
  text: 'Users Mode',
),
const SizedBox(height: 20),
Custombutton(
  buttoncolor: Appcolors.primaryColor,
  ontap: () {
    // Navigate to the UserRideHistoryScreen
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UserRideHistoryScreen(userId: widget.userId)),
    );
  },
  text: 'History Mode',
),

              ],
            );
          },
        ),
      ),
    );
  }

  
}
