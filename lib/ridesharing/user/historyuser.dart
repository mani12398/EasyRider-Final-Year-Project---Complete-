import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ridemate/utils/appcolors.dart';
import 'package:ridemate/view/Authentication/components/customappbar.dart';

class UserRideHistoryScreen extends StatelessWidget {
  final String userId;

  const UserRideHistoryScreen({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customappbar(context,
          title: 'History', backgroundColor: Appcolors.primaryColor),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Done-rides')
            .where('userid', isEqualTo: userId)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No ride history available.'));
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
    String date = ride['Date'];
    String rideid = ride['rideid'];
    String amount = ride['amount'];

    return Card(
      margin: EdgeInsets.all(8.0),
      elevation: 4,
      child: ListTile(
        title: Text('Date: $date'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
           Text('Ride ID: $rideid'),
            Text('Amount: $amount'),
          ],
        ),
      ),
    );
  }

  Future<String?> _getDriverName(String driverId) async {
    var googleUserSnapshot = await FirebaseFirestore.instance
        .collection('googleusers')
        .doc(driverId)
        .get();

    var mobileUserSnapshot = await FirebaseFirestore.instance
        .collection('mobileusers')
        .doc(driverId)
        .get();

    if (googleUserSnapshot.exists) {
      return googleUserSnapshot['Username'];
    } else if (mobileUserSnapshot.exists) {
      return mobileUserSnapshot['Username'];
    } else {
      return null;
    }
  }
}


