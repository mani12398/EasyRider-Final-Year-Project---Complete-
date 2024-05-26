import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ridemate/Providers/userdataprovider.dart';
import 'package:ridemate/utils/appcolors.dart';
import 'package:ridemate/view/Authentication/components/customappbar.dart';

class RideHistoryPage extends StatelessWidget {
  final bool isdriver;
  const RideHistoryPage({super.key, this.isdriver = false});

  Future<List<Map<String, dynamic>>> _fetchRideHistory(
      BuildContext context) async {
    final userId = Provider.of<Userdataprovider>(context, listen: false).userId;
    final querySnapshot = isdriver
        ? await FirebaseFirestore.instance
            .collection('RideRequest')
            .where('driverid', isEqualTo: userId)
            .where('Status', isEqualTo: 'Completed')
            .get()
        : await FirebaseFirestore.instance
            .collection('RideRequest')
            .where('userid', isEqualTo: userId)
            .where('Status', isEqualTo: 'Completed')
            .get();
    return querySnapshot.docs.map((doc) => doc.data()).toList();
  }

  String formatDateTime(DateTime dateTime) {
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec"
    ];
    String formattedDate =
        '${dateTime.day}-${months[dateTime.month - 1]}-${dateTime.year}';

    int hours = dateTime.hour;
    String ampm = hours >= 12 ? "PM" : "AM";
    hours = hours % 12;
    hours = hours == 0 ? 12 : hours;
    String minutes =
        dateTime.minute < 10 ? '0${dateTime.minute}' : '${dateTime.minute}';
    String formattedTime = '$hours:$minutes $ampm';

    return '$formattedDate $formattedTime';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customappbar(context,
          title: 'Ride History', backgroundColor: Colors.transparent),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _fetchRideHistory(context),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(child: Text('Error loading ride history'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No ride history found'));
            }

            final rideHistory = snapshot.data!;
            return ListView.builder(
              itemCount: rideHistory.length,
              itemBuilder: (context, index) {
                final ride = rideHistory[index];
                return Column(
                  children: [
                    _buildRideHistoryItem(
                      icons: [
                        Icons.timelapse_rounded,
                        Icons.account_circle,
                        Icons.attach_money,
                        Icons.location_city,
                        Icons.location_city,
                      ],
                      texts: [
                        formatDateTime(ride['created_at'].toDate()),
                        ride['drivername'].toString(),
                        '${ride['ridefare']}PKR',
                        ride['pickup_address'].toString(),
                        ride['destination_address'].toString(),
                      ],
                      containerColor: Appcolors.neutralgrey,
                      iconColors: [
                        Colors.red,
                        Colors.green,
                        Colors.yellow,
                        Colors.green,
                        Colors.red,
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildRideHistoryItem({
    required List<IconData> icons,
    required List<String> texts,
    required Color containerColor,
    required List<Color> iconColors,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: containerColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      icons[0],
                      size: 30,
                      color: iconColors[0],
                    ),
                    const SizedBox(width: 20),
                    Text(
                      texts[0],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Appcolors.neutralgrey700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ...List.generate(
            icons.length - 1,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  Icon(
                    icons[index + 1],
                    size: 30,
                    color: iconColors[index + 1],
                  ),
                  const SizedBox(width: 20),
                  Text(
                    texts[index + 1],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Appcolors.neutralgrey700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
