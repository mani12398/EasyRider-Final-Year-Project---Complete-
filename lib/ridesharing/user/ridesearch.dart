// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:ridemate/services/pushnotificationservice.dart';
import 'package:ridemate/utils/appcolors.dart';
import 'package:ridemate/view/Authentication/components/customappbar.dart';
//import 'package:ridemate/utils/appcolors.dart';
//import 'package:ridemate/view/Authentication/components/customappbar.dart';

class RideSearchScreen extends StatefulWidget {
  final double userDropLatitude;
  final double userDropLongitude;
  final double userstartLatitude;
  final double userstartLongitude;
  final String userid;
  final String startLocation;
  final String droplocation;
  RideSearchScreen({
    required this.userDropLatitude,
    required this.userDropLongitude,
    required this.userstartLatitude,
    required this.userstartLongitude,
    required this.droplocation,
    required this.userid,
    required this.startLocation,
  });

  @override
  _RideSearchScreenState createState() => _RideSearchScreenState();
}

class _RideSearchScreenState extends State<RideSearchScreen> {
  late List<DocumentSnapshot> _nearbyRides;
  int? _selectedRideType;

  @override
  void initState() {
    super.initState();
    _nearbyRides = [];
    _searchNearbyRides();
  }

  Future<String> _fetchDriverGender(String driverId) async {
    try {
      // Check if the driver exists in the 'drivers' collection
      DocumentSnapshot driverSnapshot = await FirebaseFirestore.instance
          .collection('drivers')
          .doc(driverId)
          .get();

      if (driverSnapshot.exists) {
        Map<String, dynamic>? data =
            driverSnapshot.data() as Map<String, dynamic>?;

        if (data != null && data.containsKey('Gender')) {
          String? gender = data['Gender'] as String?;
          if (gender != null && gender.isNotEmpty) {
            return gender;
          }
        }
      } else {
        // If driver doesn't exist in 'drivers' collection, check in 'googleusers' and 'mobileusers'
        String userGender = await _fetchUserGender(driverId);
        if (userGender.isNotEmpty) {
          return userGender;
        }
      }
    } catch (e) {
      //print('Error fetching driver gender: $e');
    }
    return '';
  }

  Future<void> _notifyDriver(String driverId) async {
    try {
      // Get the driver's token from Firestore
      DocumentSnapshot driverSnapshot = await FirebaseFirestore.instance
          .collection('drivers')
          .doc(driverId)
          .get();

      if (driverSnapshot.exists) {
        String? driverToken = driverSnapshot['token'];
        if (driverToken != null && driverToken.isNotEmpty) {
          // Send the push notification to the driver
          await PushNotificationService().sendNotification(
            driverToken,
            title: 'New Ride Request',
            bodytxt: 'You have a new ride request!',
          );
        }
      }
    } catch (e) {
      //print('Error notifying driver: $e');
    }
  }

// Function to fetch user gender from either 'googleusers' or 'mobileusers' collection
  Future<String> _fetchUserGender(String userId) async {
    try {
      // Check 'googleusers' collection first
      DocumentSnapshot googleUserSnapshot = await FirebaseFirestore.instance
          .collection('googleusers')
          .doc(userId)
          .get();

      if (googleUserSnapshot.exists) {
        Map<String, dynamic>? data =
            googleUserSnapshot.data() as Map<String, dynamic>?;
        if (data != null && data.containsKey('Gender')) {
          String? gender = data['Gender'] as String?;
          if (gender != null && gender.isNotEmpty) {
            return gender;
          }
        }
      }

      // Check 'mobileusers' collection if not found in 'googleusers'
      DocumentSnapshot mobileUserSnapshot = await FirebaseFirestore.instance
          .collection('mobileusers')
          .doc(userId)
          .get();

      if (mobileUserSnapshot.exists) {
        Map<String, dynamic>? data =
            mobileUserSnapshot.data() as Map<String, dynamic>?;
        if (data != null && data.containsKey('Gender')) {
          String? gender = data['Gender'] as String?;
          if (gender != null && gender.isNotEmpty) {
            return gender;
          }
        }
      }
    } catch (e) {
      //print('Error fetching user gender: $e');
    }
    return '';
  }

  // Method to search for nearby rides and update the UI
  void _searchNearbyRides() async {
    // Retrieve nearby rides from Firestore
    QuerySnapshot nearbyRidesSnapshot =
        await FirebaseFirestore.instance.collection('rides').get();

    // Clear previous nearby rides
    setState(() {
      _nearbyRides.clear();
    });

    bool rideFound = false;
    bool rideAvailableForUserGender = false;

    // Loop through each ride and add it to the nearby rides list if it's within the vicinity
    await Future.forEach(nearbyRidesSnapshot.docs, (ride) async {
      double rideDropLatitude = ride['droplocation']['latitude'];
      double rideDropLongitude = ride['droplocation']['longitude'];

      // Calculate the distance between user's drop location and ride's drop location
      double distance = _calculateDistance(
        widget.userDropLatitude,
        widget.userDropLongitude,
        rideDropLatitude,
        rideDropLongitude,
      );

      if (distance <= 5.0) {
        rideFound = true;
        String driverGender = await _fetchDriverGender(ride['driverid']);
        String passengerGender = await _fetchUserGender(widget.userid);
        //print('Here is your driver gender $driverGender and here is user gender $passengerGender');
        if (driverGender.isNotEmpty && passengerGender.isNotEmpty) {
          // Check if genders match
          if (driverGender == passengerGender) {
            rideAvailableForUserGender = true;
            setState(() {
              _nearbyRides.add(ride);
            });
          }
        }
      }
    });

    if (!rideFound) {
      // Display message if no rides are found nearby
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('No Rides Available'),
            content: const Text('Sorry, no rides are available nearby.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } else if (!rideAvailableForUserGender) {
      // Display message if no rides are available for the user's gender
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('No Rides Available'),
            content:
                const Text('Sorry, no rides are available for your gender.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  // Method to calculate the distance between two geographical points using Haversine formula
  double _calculateDistance(double startLatitude, double startLongitude,
      double endLatitude, double endLongitude) {
    const double earthRadius = 6371.0; // Earth radius in km
    double degreesToRadians(double degrees) => degrees * pi / 180.0;
    double latDistance = degreesToRadians(endLatitude - startLatitude);
    double lonDistance = degreesToRadians(endLongitude - startLongitude);
    double a = pow(sin(latDistance / 2), 2) +
        cos(degreesToRadians(startLatitude)) *
            cos(degreesToRadians(endLatitude)) *
            pow(sin(lonDistance / 2), 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distance = earthRadius * c;
    return distance;
  }

  String _extractAddress(String fullAddress) {
    // Split the address by commas
    List<String> addressParts = fullAddress.split(',');

    // Return the first part of the address
    // You might need to adjust this logic based on your specific address format
    return addressParts.isNotEmpty ? addressParts[0].trim() : fullAddress;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customappbar(context,
          title: 'Nearby Rides', backgroundColor: Appcolors.primaryColor),
      backgroundColor: Colors.black,
      body: ListView.builder(
        itemCount: _nearbyRides.length,
        itemBuilder: (context, index) {
          var ride = _nearbyRides[index];
          List<dynamic> person1 = List.from(ride['person1'] ?? []);
          List<dynamic> person2 = List.from(ride['person2'] ?? []);

          int capacity = ride['capacity'] ?? 0; // Total capacity of the ride
          int bookedSeatsOneWay = person1.length;
          int bookedSeatsReturnWay = person2.length;
          int availableSeatsOneWay = capacity - bookedSeatsOneWay;
          int availableSeatsReturnWay = capacity - bookedSeatsReturnWay;

          // Format start date and end date
          String startDate =
              DateFormat('dd/MM').format(ride['startingdate'].toDate());
          String endDate =
              DateFormat('dd/MM').format(ride['endingdate'].toDate());

          // Format start time and return time
          String returnTime = ride['returntime'];
          String startTime = ride['startingtime'];

          return Card(
              color: Colors.white, // Card background color
              margin: const EdgeInsets.all(8.0),
              elevation: 4, // Card elevation for a shadow effect
              child: ListTile(
                  title: Text(
                    'Ride ID: ${ride.id}',
                    style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 5),
                      Text(
                        'Start Location: ${ride['startlocation']['address']}',
                        style:
                            const TextStyle(color: Colors.black, fontSize: 14),
                      ),
                      Text(
                        'Drop Location: ${ride['droplocation']['address']}',
                        style:
                            const TextStyle(color: Colors.black, fontSize: 14),
                      ),
                      const SizedBox(height: 10),
                      // Design for one-way booking
                      Row(
                        children: [
                          const Icon(Icons.bike_scooter,
                              color: Colors.blue), // Icon for one-way booking
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              'One Way: $availableSeatsOneWay Seats',
                              style: const TextStyle(
                                  color: Colors.blue, fontSize: 14),
                            ),
                          ),
                          const SizedBox(width: 10),
                          // Show available seats as icons
                          for (int i = 0; i < availableSeatsOneWay; i++)
                            const Icon(
                                Icons.airline_seat_individual_suite_rounded,
                                color: Colors.green),
                        ],
                      ),
                      const SizedBox(height: 5),
                      // Design for return-way booking
                      Row(
                        children: [
                          const Icon(Icons.directions_rounded,
                              color:
                                  Colors.orange), // Icon for return-way booking
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              'Return Way: $availableSeatsReturnWay Seats',
                              style: const TextStyle(
                                  color: Colors.orange, fontSize: 14),
                            ),
                          ),
                          const SizedBox(width: 10),
                          // Show available seats as icons
                          for (int i = 0; i < availableSeatsReturnWay; i++)
                            const Icon(
                                Icons.airline_seat_individual_suite_rounded,
                                color: Colors.green),
                        ],
                      ),
                      const SizedBox(height: 5),
                      // Additional ride details
                      Text(
                        'Start Date: $startDate |$startTime',
                        style:
                            const TextStyle(color: Colors.black, fontSize: 14),
                      ),
                      Text(
                        'End Date: $endDate |$returnTime',
                        style:
                            const TextStyle(color: Colors.black, fontSize: 14),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () async {
                      String userId = widget.userid;
                      if (person1.contains(userId) ||
                          person2.contains(userId)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('You have already booked this ride.')),
                        );
                        return;
                      }

                      // Show the ride type selection dialog
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return RideTypeSelectionDialog(
                            onRideTypeSelected: (type) {
                              // Update the selected ride type
                              setState(() {
                                _selectedRideType = type;
                              });
                              //print('Selected Ride Type: $_selectedRideType');
                            },
                          );
                        },
                      ).then((_) async {
                        // Check if a ride type is selected
                        if (_selectedRideType != null) {
                          // Retrieve the driver ID, drop location, and ride ID
                          String driverId = ride['driverid'];
                          double dropLocationlat = widget.userDropLatitude;
                          double droplocationlng = widget.userDropLongitude;
                          double startlocatonlat = widget.userstartLatitude;
                          double startlocationlang = widget.userstartLongitude;
                          String rideId = ride.id;
                          String sl = _extractAddress(widget.startLocation);
                          String droplocation =
                              _extractAddress(widget.droplocation);

                          // Define the data to be added to Firestore
                          Map<String, dynamic> rideRequestData = {
                            'driverid': driverId,
                            'rideid': rideId,
                            'droplocation': {
                              'address': droplocation,
                              'latitude': dropLocationlat,
                              'longitude': droplocationlng,
                            },
                            'startlocation': {
                              'address': sl,
                              'latitude': startlocatonlat,
                              'longitude': startlocationlang,
                            },
                            'oneway': _selectedRideType,
                            'status': 'pending', // Set status as 'pending'
                            'userid': widget
                                .userid, // Using the userid passed from widget
                          };

                          try {
                            await FirebaseFirestore.instance
                                .collection('rideshare-request')
                                .add(rideRequestData);

                            // Notify the driver by sending a push notification
                            await _notifyDriver(driverId);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Ride request sent!')),
                            );
                            Navigator.pop(context); // Go back to user.dart
                          } catch (e) {
                            // Handle any errors that occur during adding ride request data
                            //print('Error adding ride request: $e');
                            // Show a snackbar to indicate error
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Failed to send ride request. Please try again later.',
                                ),
                              ),
                            );
                          }
                        }
                      });
                    },
                  )));
        },
      ),
    );
  }
}

class RideTypeSelectionDialog extends StatelessWidget {
  final Function(int) onRideTypeSelected;

  const RideTypeSelectionDialog({super.key, required this.onRideTypeSelected});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Ride Type'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('Start Ride (One Way)'),
            leading: const Icon(Icons.directions_bike),
            onTap: () {
              // Notify the parent widget that start ride (one-way) is selected
              onRideTypeSelected(1); // 1 for start ride (one-way)

              Navigator.of(context).pop(); // Close the dialog
            },
          ),
          ListTile(
            title: const Text('Return Ride (One Way)'),
            leading: const Icon(Icons.directions_bike),
            onTap: () {
              // Notify the parent widget that return ride (one-way) is selected
              onRideTypeSelected(2); // 2 for return ride (one-way)

              Navigator.of(context).pop(); // Close the dialog
            },
          ),
          ListTile(
            title: const Text('Two Way Ride'),
            leading: const Icon(Icons.commute),
            onTap: () {
              // Notify the parent widget that two-way ride is selected
              onRideTypeSelected(0);
              Navigator.of(context).pop(); // Close the dialog
            },
          ),
        ],
      ),
    );
  }
}
