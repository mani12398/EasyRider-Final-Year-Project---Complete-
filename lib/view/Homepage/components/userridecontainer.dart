// ignore_for_file: library_private_types_in_public_api

import 'dart:async';
import 'package:flutter/material.dart';

import '../../../widgets/custombutton.dart';
import '../../../widgets/customtext.dart';

class UserRideContainer extends StatefulWidget {
  final String transportName;
  final String driverName;
  final String driverfare;
  final String durationTxt;
  final String distanceTxt;
  final Function onAccept;
  final String driverid;

  const UserRideContainer({
    super.key,
    required this.transportName,
    required this.driverName,
    required this.durationTxt,
    required this.distanceTxt,
    required this.onAccept,
    required this.driverfare,
    required this.driverid,
  });

  @override
  _UserRideContainerState createState() => _UserRideContainerState();
}

class _UserRideContainerState extends State<UserRideContainer> {
  double _progress = 1.0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startProgress();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startProgress() {
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        _progress -= 0.0033;
        if (_progress <= 0) {
          _progress = 0;
          _timer?.cancel();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.lightGreen,
        borderRadius: BorderRadius.circular(10.0),
      ),
      width: MediaQuery.of(context).size.width,
      height: 200,
      margin: const EdgeInsets.only(left: 10.0, right: 10.0, top: 16.0),
      child: Stack(
        children: [
          StatefulBuilder(
            builder: (context, setState) => LinearProgressIndicator(
              value: _progress,
              backgroundColor: Colors.white,
              color: Colors.green,
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 10.0, top: 10.0),
            child: Align(
              alignment: Alignment.topLeft,
              child: CircleAvatar(
                radius: 40,
                backgroundImage: AssetImage('assets/personimage.jpg'),
              ),
            ),
          ),
          Positioned(
            top: 16.0,
            left: 105.0,
            child: CustomText(
              title: widget.transportName,
              fontSize: 16.0,
              color: Colors.black,
            ),
          ),
          Positioned(
            top: 64.0,
            left: 105.0,
            child: CustomText(
              title: widget.driverName,
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Positioned(
            top: 16.0,
            right: 10.0,
            child: CustomText(
              title: '${widget.driverfare}PKR',
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          Positioned(
            top: 50.0,
            right: 10.0,
            child: CustomText(
              title: widget.durationTxt,
              fontSize: 16.0,
              color: Colors.black,
            ),
          ),
          Positioned(
            top: 80.0,
            right: 10.0,
            child: CustomText(
              title: widget.distanceTxt,
              fontSize: 16.0,
              color: Colors.black,
            ),
          ),
          Positioned(
            bottom: 10.0,
            left: 0.0,
            right: 0.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Custombutton(
                  text: 'Accept',
                  ontap: () async {
                    await widget.onAccept(
                      widget.driverid,
                      context,
                      int.parse(widget.driverfare),
                    );
                  },
                  fontSize: 16,
                  borderRadius: 8,
                  height: 50,
                  width: 130,
                  fontWeight: FontWeight.bold,
                ),
                Custombutton(
                  text: 'Decline',
                  ontap: () {},
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  borderRadius: 8,
                  height: 50,
                  width: 130,
                  fontColor: Colors.red,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
