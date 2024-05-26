// ignore_for_file: library_private_types_in_public_api

import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:ridemate/ridesharing/user/locationtesting.dart';
import 'package:ridemate/utils/appcolors.dart';
import 'package:ridemate/view/Authentication/components/customappbar.dart';

class AddRideScreen extends StatefulWidget {
  final String userId;

  const AddRideScreen({super.key, required this.userId});

  @override
  _AddRideScreenState createState() => _AddRideScreenState();
}

class _AddRideScreenState extends State<AddRideScreen> {
  TextEditingController startLocationController = TextEditingController();
  TextEditingController dropLocationController = TextEditingController();
  double? dropLatitude;
  double? dropLongitude;
  double? startlatitude;
  double? startlongitude;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _capacity = '1';
  DateTime _startingDate = DateTime.now();
  DateTime _endDate = DateTime.now();
  TimeOfDay _returnTime = const TimeOfDay(hour: 0, minute: 0);
  TimeOfDay _startingTime = const TimeOfDay(hour: 0, minute: 0);

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: customappbar(context,
          title: 'Add Ride', backgroundColor: Appcolors.primaryColor),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 241, 241, 240),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildInfoForm(),
                  const SizedBox(height: 20.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Appcolors.primaryColor,
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        ),
                        child: const Text('Back'),
                      ),
                      ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: theme.primaryColor,
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        ),
                        child: const Text('Submit'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _textField(
            label: 'Start Location',
            hint: 'Choose starting point',
            controller: startLocationController,
            onTap: () => _selectLocation(startLocationController, true),
            iconPath: 'assets/location.gif', // Set the path of the icon
          ),
          const SizedBox(height: 10.0),
          _textField(
            label: 'Drop Location',
            hint: 'Choose drop point',
            controller: dropLocationController,
            onTap: () => _selectLocation(dropLocationController, false),
            iconPath: 'assets/location.gif', // Set the path of the icon
          ),
          const SizedBox(height: 10.0),
          _buildDateField(context),
          const SizedBox(
            height: 16.0,
          ),
          _buildEndDateField(context),
          const SizedBox(height: 16.0),
          _buildTimeField(context, 'Return Time:', _returnTime,
              isReturnTime: true),
          const SizedBox(height: 16.0),
          _buildTimeField(context, 'Starting Time:', _startingTime,
              isReturnTime: false),
          const SizedBox(height: 16.0),
          _buildCapacityDropdown(),
        ],
      ),
    );
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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildCapacityDropdown() {
    return DropdownButtonFormField<String>(
      value: _capacity,
      decoration: InputDecoration(
        labelText: 'Capacity',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      items: ['1', '2', '3', '4']
          .map<DropdownMenuItem<String>>(
            (String value) => DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            ),
          )
          .toList(),
      onChanged: (newValue) {
        setState(() {
          _capacity = newValue!;
        });
      },
    );
  }

  Widget _buildDateField(BuildContext context) {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: AbsorbPointer(
        child: TextFormField(
          decoration: InputDecoration(
            labelText:
                'Starting Date: ${DateFormat('yyyy-MM-dd').format(_startingDate)}',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            filled: true,
            fillColor: Colors.white,
            suffixIcon: const Icon(Icons.calendar_today),
          ),
        ),
      ),
    );
  }

  Widget _buildEndDateField(BuildContext context) {
    return GestureDetector(
      onTap: () => _selectEndDate(context),
      child: AbsorbPointer(
        child: TextFormField(
          decoration: InputDecoration(
            labelText: 'End Date: ${DateFormat('yyyy-MM-dd').format(_endDate)}',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            filled: true,
            fillColor: Colors.white,
            suffixIcon: const Icon(Icons.calendar_today),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startingDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _startingDate) {
      setState(() {
        _startingDate = picked;
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  Widget _buildTimeField(BuildContext context, String label, TimeOfDay time,
      {required bool isReturnTime}) {
    return GestureDetector(
      onTap: () => _selectTime(context, isReturnTime: isReturnTime),
      child: AbsorbPointer(
        child: TextFormField(
          decoration: InputDecoration(
            labelText: '$label ${_formatTimeOfDay(time)}',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            filled: true,
            fillColor: Colors.white,
            suffixIcon: const Icon(Icons.access_time),
          ),
        ),
      ),
    );
  }

  Future<void> _selectTime(BuildContext context,
      {required bool isReturnTime}) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isReturnTime ? _returnTime : _startingTime,
    );
    if (picked != null) {
      setState(() {
        if (isReturnTime) {
          _returnTime = picked;
        } else {
          _startingTime = picked;
        }
      });
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

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      String startLocation = startLocationController.text.trim();
      String dropLocation = dropLocationController.text.trim();

      if (startLocation.isNotEmpty && dropLocation.isNotEmpty) {
        // Validate if dates are in the same week
        if (!_isSameWeek(_startingDate, _endDate)) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Invalid Dates'),
              content: const Text(
                  'The start date and end date must be within the same week.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
          return;
        }

        // Calculate distance between start and drop locations
        double distance = _calculateDistance(
            startlatitude!, startlongitude!, dropLatitude!, dropLongitude!);

        int numberOfDays = _endDate.difference(_startingDate).inDays;

        double totalRideFare = _calculateRideFare(distance);
        totalRideFare *= 2 * numberOfDays;
        int roundedFare = totalRideFare.round();
        FirebaseFirestore.instance.collection('rides').add({
          'driverid': widget.userId,
          'startlocation': {
            'address': startLocation,
            'latitude': startlatitude,
            'longitude': startlongitude,
          },
          'droplocation': {
            'address': dropLocation,
            'latitude': dropLatitude,
            'longitude': dropLongitude,
          },
          'status': 'active',
          'capacity': int.parse(_capacity),
          'returntime': _formatTimeOfDay(_returnTime),
          'startingdate': Timestamp.fromDate(_startingDate),
          'endingdate': Timestamp.fromDate(_endDate),
          'startingtime': _formatTimeOfDay(_startingTime),
          'ridefare': roundedFare,
          'person1': [],
          'person2': [],
        }).then((value) {
          // Handle success
          Navigator.of(context).pop();
          //print('Ride added successfully!');
          startLocationController.clear();
          dropLocationController.clear();
        }).catchError((error) {
          //print('Failed to add ride: $error');
        });
      } else {
        //print('Please select both start and drop locations.');
      }
    }
  }

  bool _isSameWeek(DateTime start, DateTime end) {
    int startWeek = _weekNumber(start);
    int endWeek = _weekNumber(end);
    return startWeek == endWeek && start.year == end.year;
  }

  int _weekNumber(DateTime date) {
    int dayOfYear = int.parse(DateFormat("D").format(date));
    return ((dayOfYear - date.weekday + 10) / 7).floor();
  }

  double _calculateRideFare(double distance) {
    double petrolRequired = distance / 12;
    double petrolCost = petrolRequired * 300; // Petrol price: Rs 266 per liter

    // Add profit margins for company and driver
    double companyProfit = petrolCost * 0.1; // 10% profit for company

    // Calculate total ride fare
    return petrolCost + companyProfit;
  }

  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const double pi = 3.1415926535897932;
    const double earthRadius = 6378.137; // Radius of the Earth in kilometers
    double dLat = (lat2 - lat1) * pi / 180;
    double dLon = (lon2 - lon1) * pi / 180;
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / 180) *
            cos(lat2 * pi / 180) *
            sin(dLon / 2) *
            sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c; // Distance in kilometers
  }

  String _formatTimeOfDay(TimeOfDay timeOfDay) {
    final String formattedHour =
        timeOfDay.hour < 10 ? '0${timeOfDay.hour}' : '${timeOfDay.hour}';
    final String formattedMinute =
        timeOfDay.minute < 10 ? '0${timeOfDay.minute}' : '${timeOfDay.minute}';
    return '$formattedHour:$formattedMinute';
  }
}
