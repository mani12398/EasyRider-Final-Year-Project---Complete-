import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ridemate/ridesharing/driver/startride.dart';
//import 'package:ridemate/ridesharing/driver/startride.dart';
import 'package:ridemate/utils/appcolors.dart';
import 'package:ridemate/view/Authentication/components/customappbar.dart';
import 'package:ridemate/widgets/custombutton.dart';
//import 'package:flutter_application_1/driver/startride.dart';

class DriverRideHistoryScreen extends StatelessWidget {
  final String userId;

  const DriverRideHistoryScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customappbar(context,
          title: 'Ride History', backgroundColor: Appcolors.primaryColor),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('rides')
            .where('driverid', isEqualTo: userId)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Appcolors.primaryColor),
            ));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No ride history available.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var ride = snapshot.data!.docs[index];
              return _buildRideCard(context, ride);
            },
          );
        },
      ),
    );
  }

  Widget _buildRideCard(BuildContext context, QueryDocumentSnapshot ride) {
    var person1Data = ride['person1'];
    var person2Data = ride['person2'];

    List<dynamic> person1 = person1Data is List ? person1Data : [];
    List<dynamic> person2 = person2Data is List ? person2Data : [];
    int capacity = ride['capacity'] ?? 0; // Total capacity of the ride
    int bookedSeatsOneWay = person1.length;
    int bookedSeatsReturnWay = person2.length;
    int availableSeatsOneWay = capacity - bookedSeatsOneWay;
    int availableSeatsReturnWay = capacity - bookedSeatsReturnWay;

    // Calculate total days of the ride
    DateTime startingDate = (ride['startingdate'] as Timestamp).toDate();
    DateTime endingDate = (ride['endingdate'] as Timestamp).toDate();
    int totalDays = endingDate.difference(startingDate).inDays +
        1; // Add 1 to include the starting day

    // Calculate ride cost per day
    int rideFare = ride['ridefare'] ?? 0;

    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 4,
      child: ListTile(
        title: Text(
          'Ride ID: ${ride.id}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 5),
            Text(
              'Start Location: ${ride['startlocation']['address']}',
              style: const TextStyle(fontSize: 14),
            ),
            Text(
              'Drop Location: ${ride['droplocation']['address']}',
              style: const TextStyle(fontSize: 14),
            ),
            Text('Total Capacity: $capacity'),
            const SizedBox(height: 5),
            // Show available seats for one-way booking
            Row(
              children: [
                const Icon(Icons.directions_bike, size: 16, color: Colors.blue),
                const SizedBox(width: 5),
                Text(
                  'One Way: $availableSeatsOneWay Seats',
                  style: const TextStyle(color: Colors.blue, fontSize: 14),
                ),
                const Spacer(),
                // Show available seats as icons
                for (int i = 0; i < availableSeatsOneWay; i++)
                  const Icon(Icons.airline_seat_individual_suite_rounded,
                      color: Colors.green),
              ],
            ),
            const SizedBox(height: 5),
            // Show available seats for return-way booking
            Row(
              children: [
                const Icon(Icons.directions_car,
                    size: 16, color: Appcolors.primaryColor),
                const SizedBox(width: 5),
                Text(
                  'Return Way: $availableSeatsReturnWay Seats',
                  style: const TextStyle(
                      color: Appcolors.primaryColor, fontSize: 14),
                ),
                const Spacer(),
                // Show available seats as icons
                for (int i = 0; i < availableSeatsReturnWay; i++)
                  const Icon(Icons.airline_seat_individual_suite_rounded,
                      color: Colors.green),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              'Ride Fare: $rideFare Rs',
              style: const TextStyle(fontSize: 14),
            ),
            Text(
              'Trip days : $totalDays',
              style: const TextStyle(fontSize: 14),
            ),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Custombutton(
                      text: 'Bookings',
                      fontSize: 16,
                      height: 30,
                      width: 170,
                      fontWeight: FontWeight.w500,
                      borderRadius: 8,
                      ontap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                BookingScreen(rideId: ride.id),
                          ),
                        );
                      },
                    ),
                    Custombutton(
                      text: 'Start Ride',
                      fontSize: 16,
                      height: 30,
                      width: 130,
                      fontWeight: FontWeight.w500,
                      borderRadius: 8,
                      ontap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Startride(rideid: ride.id),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Custombutton(
                  text: 'Delete Ride',
                  fontSize: 16,
                  height: 30,
                  width: 130,
                  fontWeight: FontWeight.w500,
                  borderRadius: 8,
                  ontap: () {
                    _deleteRide(ride.id);
                  },
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _deleteRide(String rideId) {
    // Delete the ride from 'rides' collection
    FirebaseFirestore.instance.collection('rides').doc(rideId).delete();

    // Delete associated bookings from 'booking' collection
    FirebaseFirestore.instance
        .collection('booking')
        .where('rideid', isEqualTo: rideId)
        .get()
        .then((QuerySnapshot snapshot) {
      for (QueryDocumentSnapshot doc in snapshot.docs) {
        doc.reference.delete();
      }
    });
  }
}

class BookingScreen extends StatelessWidget {
  final String rideId;

  const BookingScreen({Key? key, required this.rideId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookings'),
        backgroundColor: const Color(0xffEDAE10),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('booking')
            .where('rideid', isEqualTo: rideId)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No bookings available for this ride.'),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var booking = snapshot.data!.docs[index];
              return _buildBookingCard(context, booking);
            },
          );
        },
      ),
    );
  }

  Widget _buildBookingCard(
      BuildContext context, QueryDocumentSnapshot booking) {
    return FutureBuilder<DocumentSnapshot>(
      future: _getPassengerData(booking['userid']),
      builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const ListTile(
            title: Text('Loading...'),
          );
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const ListTile(
            title: Text('Passenger not found'),
          );
        }

        var user = snapshot.data!.data() as Map<String, dynamic>;

        String contactInfo = '';

        if (user['provider'] == 'google') {
          // Display email if it's a Google account
          contactInfo = user['Email'] ?? 'No Email';
        } else {
          // Display phone number if it's from mobile users
          contactInfo = user['phoneNumber'] ?? 'No Phone Number';
        }

        return Card(
          margin: const EdgeInsets.all(8.0),
          color: user['provider'] == 'google'
              ? const Color.fromARGB(255, 247, 248, 248)
              : Color.fromARGB(255, 255, 255, 255), // Change color based on user provider
          elevation: 4,
          child: ListTile(
            title: Text(
              user['Username'] ?? 'No Name',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 5),
                Text(
                  'Contact Info: $contactInfo',
                  style: const TextStyle(fontSize: 14),
                ),
                Text(
                  'Start Location: ${booking['userstartlocation']['address']}',
                  style: const TextStyle(fontSize: 14),
                ),
                Text(
                  'Drop Location: ${booking['userdroplocation']['address']}',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 5),
                Text(
                  'Ride Fare: ${booking['ridefare']}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<DocumentSnapshot> _getPassengerData(String userId) async {
    // Check if the user exists in the 'googleusers' collection
    var googleUserSnapshot = await FirebaseFirestore.instance
        .collection('googleusers')
        .doc(userId)
        .get();

    // Check if the user exists in the 'mobileusers' collection
    var mobileUserSnapshot = await FirebaseFirestore.instance
        .collection('mobileusers')
        .doc(userId)
        .get();

    // Return the document snapshot based on the availability in collections
    if (googleUserSnapshot.exists) {
      return googleUserSnapshot;
    } else if (mobileUserSnapshot.exists) {
      return mobileUserSnapshot;
    } else {
      // Return an empty document snapshot if user data is not found
      return FirebaseFirestore.instance.collection('dummy').doc(userId).get();
    }
  }
}
