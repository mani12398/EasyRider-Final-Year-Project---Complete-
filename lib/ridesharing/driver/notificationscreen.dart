import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ridemate/ridesharing/driver/changeloc.dart';
import 'package:ridemate/services/pushnotificationservice.dart';
//import 'package:ridemate/ridesharing/driver/changeloc.dart';
import 'package:ridemate/utils/appcolors.dart';
import 'package:ridemate/view/Authentication/components/customappbar.dart';

class NotificationsScreen extends StatelessWidget {
  final String driverid;

  const NotificationsScreen({super.key, required this.driverid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customappbar(context,
          title: 'Ride Requests', backgroundColor: Appcolors.primaryColor),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('rideshare-request')
            .where('driverid', isEqualTo: driverid)
            .where('status', isEqualTo: 'pending')
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No pending ride requests'));
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var request = snapshot.data!.docs[index];
                    return _buildRequestCard(context, request);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRequestCard(
    BuildContext context,
    QueryDocumentSnapshot request,
  ) {
    return FutureBuilder<String>(
      future: _fetchUserName(request['userid']),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        String userName = snapshot.data ?? 'Unknown';
        String onewayText;
        if (request['oneway'] == 1) {
          onewayText = 'Start ride';
        } else if (request['oneway'] == 2) {
          onewayText = 'Return ride';
        } else {
          onewayText = 'Two-way ride';
        }

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          color: const Color.fromARGB(255, 216, 215, 211),
          elevation: 4.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: ListTile(
            title: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black),
                children: [
                  const TextSpan(
                    text: 'Username: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: '$userName'),
                ],
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Start Location: ${request['startlocation']['address']}',
                  style: const TextStyle(color: Colors.black),
                ),
                Text(
                  'Drop Location: ${request['droplocation']['address']}',
                  style: const TextStyle(color: Colors.black),
                ),
                Text(
                  'Ride Status: $onewayText',
                  style: const TextStyle(color: Colors.black),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.location_on), // Add location icon
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LocationSelectionPage(
                          requestId: request.id,
                        ),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    _removeRideRequest(context, request.id);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    _acceptRideRequest(context, request.id);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<String> _fetchUserName(String userId) async {
    try {
      DocumentSnapshot googleUserSnapshot = await FirebaseFirestore.instance
          .collection('googleusers')
          .doc(userId)
          .get();

      if (googleUserSnapshot.exists) {
        return googleUserSnapshot.get('Username') as String;
      }

      DocumentSnapshot mobileUserSnapshot = await FirebaseFirestore.instance
          .collection('mobileusers')
          .doc(userId)
          .get();

      if (mobileUserSnapshot.exists) {
        return mobileUserSnapshot.get('Username') as String;
      }
    } catch (e) {
      //print('Error fetching user name: $e');
    }

    return 'shami'; // Return empty string if user not found
  }

  double _calculateDistance(
      double startLat, double startLng, double endLat, double endLng) {
    const double earthRadius = 6371.0; // Radius of the Earth in kilometers
    double latDistance = _toRadians(endLat - startLat);
    double lngDistance = _toRadians(endLng - startLng);
    double a = pow(sin(latDistance / 2), 2) +
        cos(_toRadians(startLat)) *
            cos(_toRadians(endLat)) *
            pow(sin(lngDistance / 2), 2);
    double c = 2 * asin(sqrt(a));
    return earthRadius * c;
  }

  double _toRadians(double degree) {
    return degree * (pi / 180.0);
  }

  double _calculateFare(double distance) {
    double fuelConsumption = distance / 12;
    double fuelCost =
        fuelConsumption * 170; // Fuel cost without additional charges
    double companyCharge = fuelCost * 0.005; // 0.5% of fuel cost
    double driverProfit = fuelCost * 0.002; // 0.2% of fuel cost
    return fuelCost + companyCharge + driverProfit; // Total fare
  }

  void _removeRideRequest(BuildContext context, String requestId) {
    FirebaseFirestore.instance
        .collection('rideshare-request')
        .doc(requestId)
        .delete()
        .then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ride request removed successfully!'),
        ),
      );
    }).catchError((error) {
      //print('Failed to remove ride request: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Failed to remove ride request. Please try again later.'),
        ),
      );
    });
  }

  Future<void> _sendNotificationToUser(String userId) async {
    try {
      // Get the driver's token from Firestore
      DocumentSnapshot usersnapshot = await FirebaseFirestore.instance
          .collection('users-token')
          .doc(userId)
          .get();

      if (usersnapshot.exists) {
        String? driverToken = usersnapshot['token'];
        if (driverToken != null && driverToken.isNotEmpty) {
          // Send the push notification to the driver
          await PushNotificationService().sendNotification(
            driverToken,
            title: 'Request Accepted',
            bodytxt: 'Your ride request is accepted!',
          );
        }
      }
    } catch (e) {
      //print('Error notifying driver: $e');
    }
  }

  void _acceptRideRequest(BuildContext context, String requestId) {
    FirebaseFirestore.instance
        .collection('rideshare-request')
        .doc(requestId)
        .get()
        .then((requestSnapshot) {
      if (requestSnapshot.exists) {
        var rideData = requestSnapshot.data();
        String rideId = rideData?['rideid'];

        // Check for null values in start location and drop location
        var startLocation = rideData?['startlocation'];
        var dropLocation = rideData?['droplocation'];

        if (startLocation == null || dropLocation == null) {
          //print('Start location or drop location is null');
          return;
        }

        double distance = _calculateDistance(
          startLocation['latitude'],
          startLocation['longitude'],
          dropLocation['latitude'],
          dropLocation['longitude'],
        );

        int fare = _calculateFare(distance).toInt();

        String userId = rideData?['userid'] ?? '';
        List<dynamic> person1 = [];
        List<dynamic> person2 = [];

        int rideType = rideData?['oneway'] ?? 0;

        // Determine whether to add user to person1 or person2 based on ride type
        if (rideType == 1) {
          person1.add(userId);
        } else if (rideType == 2) {
          person2.add(userId);
        } else {
          person1.add(userId);
          person2.add(userId);
          fare = fare + fare;
        }

        // Update person1 and person2 arrays in rides collection
        FirebaseFirestore.instance.collection('rides').doc(rideId).update({
          'person1': FieldValue.arrayUnion(person1),
          'person2': FieldValue.arrayUnion(person2),
        }).then((_) {
          //print('Person 1 and Person 2 updated successfully');
        }).catchError((error) {
          //print('Failed to update Person 1 and Person 2: $error');
        });

        // Add booking details...
        FirebaseFirestore.instance.collection('booking').add({
          'driverid': rideData?['driverid'] ?? '',
          'rideid': rideId,
          'ridefare': fare.toString(),
          'userstartlocation': {
            'address': startLocation['address'],
            'latitude': startLocation['latitude'],
            'longitude': startLocation['longitude'],
          },
          'userdroplocation': {
            'address': dropLocation['address'],
            'latitude': dropLocation['latitude'],
            'longitude': dropLocation['longitude'],
          },
          'userid': userId,
          'livelocation': ''
        }).then((_) {
          //print('Booking details added successfully');
        }).catchError((error) {
          //print('Failed to add booking details: $error');
        });
        _sendNotificationToUser(userId);
        // Delete the ride request from the riderequest collection
        FirebaseFirestore.instance
            .collection('rideshare-request')
            .doc(requestId)
            .delete()
            .then((_) {
          //print('Ride request deleted successfully');
        }).catchError((error) {
          //print('Failed to delete ride request: $error');
        });
      } else {
        //print('Ride request document not found');
      }
    }).catchError((error) {
      //print('Error retrieving ride request document: $error');
      // Show a snack bar in case of error
      if (context != null && ScaffoldMessenger.of(context).mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Failed to accept ride request. Please try again later.'),
          ),
        );
      }
    });
  }
}
