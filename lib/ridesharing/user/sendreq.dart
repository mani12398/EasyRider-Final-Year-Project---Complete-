import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart' as location;
import 'package:intl/intl.dart';
import 'package:ridemate/ridesharing/user/locationtesting.dart';
import 'package:ridemate/ridesharing/user/ridesearch.dart';
import 'package:ridemate/utils/appcolors.dart';
import 'package:ridemate/view/Authentication/components/customappbar.dart';
import 'package:ridemate/widgets/custombutton.dart';
// Import the custom location search screen

class Sendrequest extends StatefulWidget {
  final String userId;

  Sendrequest({required this.userId});

  @override
  _SendrequestState createState() => _SendrequestState();
}

class _SendrequestState extends State<Sendrequest> {
  location.Location _location = location.Location();
  TextEditingController startLocationController = TextEditingController();
  TextEditingController dropLocationController = TextEditingController();
  double? dropLatitude;
  double? dropLongitude;
  double? startlatitude;
  double? startlongitude;

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _getLocation();
  }

  void _getLocation() async {
    try {
      var userLocation = await _location.getLocation();
      setState(() {});
    } catch (e) {
      //print("Error: $e");
    }
  }

  void _selectLocation(TextEditingController controller, bool isStartLocation) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GoogleMapSearchPlacesApi(
          onLocationSelected: (address, lat, lng) {
            setState(() {
              controller.text = address;
              if (isStartLocation) {
                startlatitude = lat;
                startlongitude = lng;
              } else {
                dropLatitude = lat;
                dropLongitude = lng;
              }
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customappbar(context,
          title: 'Search Ride', backgroundColor: Appcolors.primaryColor),
      body: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white70,
                  borderRadius: BorderRadius.circular(20.0),
                ),
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    _textField(
                      label: 'Start Location',
                      hint: 'Choose starting point',
                      controller: startLocationController,
                      onTap: () =>
                          _selectLocation(startLocationController, true),
                      iconPath:
                          'assets/location.gif', // Set the path of the icon
                    ),
                    const SizedBox(height: 10.0),
                    _textField(
                      label: 'Drop Location',
                      hint: 'Choose drop point',
                      controller: dropLocationController,
                      onTap: () =>
                          _selectLocation(dropLocationController, false),
                      iconPath:
                          'assets/location.gif', // Set the path of the icon
                    ),
                    const SizedBox(height: 8.0),
                    Custombutton(
                      buttoncolor: Appcolors.primaryColor,
                      ontap: () {
                        if (dropLatitude != null && startlatitude != null) {
                          // Navigate to RideSearchScreen and pass latitude and longitude
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RideSearchScreen(
                                userDropLatitude: dropLatitude!,
                                userDropLongitude: dropLongitude!,
                                userstartLatitude: startlatitude!,
                                userstartLongitude: startlongitude!,
                                userid: widget.userId,
                                startLocation: startLocationController.text,
                                droplocation: dropLocationController.text,
                              ),
                            ),
                          );
                        } else {
                          // Handle case where drop location is not selected
                          //print('Please select drop location');
                        }
                      },
                      text: 'Search rides',
                    ),
                  ],
                ),
              ),
              const Divider(
                height: 20.0,
                thickness: 3.0,
                color: Color.fromARGB(255, 20, 23, 26),
                indent: 25.0,
                endIndent: 25.0,
              ),
              RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: 'Available ',
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
                      text: 'Rides',
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
              const Divider(
                height: 20.0,
                thickness: 3.0,
                color: Color.fromARGB(255, 19, 16, 16),
                indent: 25.0,
                endIndent: 25.0,
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.center,
                  child: SingleChildScrollView(
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      child: StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('rides')
                            .snapshots(),
                        builder:
                            (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: (context, index) {
                              var ride = snapshot.data!.docs[index];
                              List<dynamic> person1 =
                                  List.from(ride['person1'] ?? []);
                              List<dynamic> person2 =
                                  List.from(ride['person2'] ?? []);

                              int capacity = ride['capacity'] ??
                                  0; // Parse capacity as an integer

                              int bookedSeatsOneWay = person1.length;
                              int bookedSeatsReturnWay = person2.length;
                              int availableSeatsOneWay =
                                  capacity - bookedSeatsOneWay;
                              int availableSeatsReturnWay =
                                  capacity - bookedSeatsReturnWay;

                              DateTime startingDate =
                                  (ride['startingdate'] as Timestamp).toDate();
                              DateTime endingDate =
                                  (ride['endingdate'] as Timestamp).toDate();
                              String startDate =
                                  DateFormat('dd/MM').format(startingDate);
                              String endDate =
                                  DateFormat('dd/MM').format(endingDate);
                              String returnTime = ride['returntime']
                                  .toString(); // Assuming returntime is a string
                              String startTime = ride['startingtime']
                                  .toString(); // Assuming startingtime is a string

                              return Card(
                                margin:
                                    const EdgeInsets.symmetric(vertical: 5.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                elevation: 3,
                                color: const Color.fromARGB(255, 238, 236, 215),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Align(
                                        alignment: Alignment.topRight,
                                        child: Container(
                                          padding: const EdgeInsets.all(5.0),
                                          decoration: const BoxDecoration(),
                                          child: Text(
                                            '$startDate - $endDate | $startTime - $returnTime',
                                            style: const TextStyle(
                                              fontSize: 12.0,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 10.0),
                                      const Row(
                                        children: [
                                          Icon(Icons.location_on,
                                              color: Colors.black),
                                          SizedBox(width: 5.0),
                                          Text(
                                            'Start Location',
                                            style: TextStyle(
                                              fontSize: 18.0,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 5.0),
                                      Text(
                                        _extractAddress(
                                            ride['startlocation']['address']),
                                        style: const TextStyle(
                                            fontSize: 16.0,
                                            color: Colors.black),
                                      ),
                                      const SizedBox(height: 10.0),
                                      const Row(
                                        children: [
                                          Icon(Icons.location_on,
                                              color: Colors.black),
                                          SizedBox(width: 5.0),
                                          Text(
                                            'Drop Location',
                                            style: TextStyle(
                                              fontSize: 18.0,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 5.0),
                                      Text(
                                        _extractAddress(
                                            ride['droplocation']['address']),
                                        style: const TextStyle(
                                            fontSize: 16.0,
                                            color: Colors.black),
                                      ),
                                      const SizedBox(height: 10.0),
                                      Row(
                                        children: [
                                          const Icon(Icons.people,
                                              color: Colors.black),
                                          const SizedBox(width: 5.0),
                                          Text(
                                            'Capacity: ${ride['capacity']} Persons',
                                            style: const TextStyle(
                                                fontSize: 16.0,
                                                color: Colors.black),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10.0),
                                      Row(
                                        children: [
                                          const Icon(Icons.bike_scooter,
                                              color: Colors.blue),
                                          const SizedBox(width: 5),
                                          Expanded(
                                            child: Text(
                                              'One Way: $availableSeatsOneWay Seats',
                                              style: const TextStyle(
                                                  color: Colors.blue,
                                                  fontSize: 14),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          for (int i = 0;
                                              i < availableSeatsOneWay;
                                              i++)
                                            const Icon(
                                                Icons
                                                    .airline_seat_individual_suite_rounded,
                                                color: Colors.green),
                                        ],
                                      ),
                                      const SizedBox(height: 5),
                                      Row(
                                        children: [
                                          const Icon(Icons.directions_rounded,
                                              color: Colors.orange),
                                          const SizedBox(width: 5),
                                          Expanded(
                                            child: Text(
                                              'Return Way: $availableSeatsReturnWay Seats',
                                              style: const TextStyle(
                                                  color: Colors.orange,
                                                  fontSize: 14),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          for (int i = 0;
                                              i < availableSeatsReturnWay;
                                              i++)
                                            const Icon(
                                                Icons
                                                    .airline_seat_individual_suite_rounded,
                                                color: Colors.green),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _extractAddress(String fullAddress) {
    int index = fullAddress.toLowerCase().indexOf('islamabad');

    if (index != -1) {
      return fullAddress.substring(0, index).trim();
    } else {
      return fullAddress;
    }
  }

  Widget _textField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required Function onTap,
    required String iconPath,
  }) {
    return TextField(
      controller: controller,
      onTap: () => onTap(),
      decoration: InputDecoration(
        contentPadding:
            const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
        labelText: label,
        hintText: hint,
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 10.0, right: 10.0),
          child: Image.asset(
            iconPath,
            width: 20.0, // Set the width of the icon
            height: 20.0, // Set the height of the icon
          ),
        ),
        border: InputBorder.none, // Remove the border
      ),
    );
  }
}
