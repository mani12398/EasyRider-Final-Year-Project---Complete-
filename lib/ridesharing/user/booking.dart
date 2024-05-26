import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ridemate/ridesharing/user/livelocation.dart';
//import 'package:ridemate/ridesharing/user/livelocation.dart';
import 'package:ridemate/utils/appcolors.dart';
import 'package:ridemate/view/Authentication/components/customappbar.dart';
//import 'package:flutter_application_1/user/livelocation.dart';

class booking extends StatelessWidget {
  final String userId;
  booking({required this.userId});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customappbar(context,
          title: 'Bookings', backgroundColor: Appcolors.primaryColor),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('booking')
            .where('userid', isEqualTo: userId)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No bookings available'));
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
  String bookingId = booking.id; // Get the booking ID from the current snapshot

  return Card(
    margin: const EdgeInsets.all(8.0),
    elevation: 4.0,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('Start Location: ${booking['userstartlocation.address']}'),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('Drop Location: ${booking['userdroplocation.address']}'),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('Ride Fare: ${booking['ridefare']} Rs'),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DriverLocationScreen(),
                  ),
                );
              },
              icon: const Icon(
                Icons.directions,
                color: Colors.white,
              ),
              label: const Text(
                'Track Driver',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                _deleteBooking(context, bookingId);
              },
              icon: const Icon(
                Icons.delete,
                color: Colors.white,
              ),
              label: const Text(
                'Delete',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}


  void _deleteBooking(BuildContext context, String bookingId) {
    FirebaseFirestore.instance
        .collection('booking')
        .doc(bookingId)
        .get()
        .then((bookingSnapshot) async {
      if (bookingSnapshot.exists) {
        var bookingData = bookingSnapshot.data();
        String rideId = bookingData?['rideid'];
        String userId = bookingData?['userid'];
        //print('User $userId and $rideId');
        if (rideId != null && userId != null) {
          // Remove user ID from person1 and person2 arrays in the rides collection
          await FirebaseFirestore.instance
              .collection('rides')
              .doc(rideId)
              .update({
            'person1': FieldValue.arrayRemove([userId]),
            'person2': FieldValue.arrayRemove([userId]),
          });

          //print('User removed from ride document successfully');
        }

        // Delete the booking from the 'booking' collection
        await FirebaseFirestore.instance
            .collection('booking')
            .doc(bookingId)
            .delete();
        //print('Booking deleted successfully');
      }
    }).catchError((error) {
      //print('Error deleting booking: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to delete booking. Please try again later.'),
        ),
      );
    });
  }
}
