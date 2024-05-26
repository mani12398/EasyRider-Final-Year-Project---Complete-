// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ridemate/utils/appcolors.dart';
import 'package:ridemate/view/Authentication/components/customappbar.dart';
import 'package:ridemate/view/Cancelride/cancelridealert.dart';
import 'package:ridemate/widgets/custombutton.dart';
import 'package:ridemate/widgets/customtext.dart';

import '../../services/pushnotificationservice.dart';
import '../Homepage/components/paycash.dart';

class CancelridePage extends StatefulWidget {
  final String rideid;
  final bool afterbooking;
  final String driverid;
  const CancelridePage(
      {super.key,
      required this.rideid,
      this.afterbooking = false,
      this.driverid = ''});

  @override
  // ignore: library_private_types_in_public_api
  _CancelridePageState createState() => _CancelridePageState();
}

class _CancelridePageState extends State<CancelridePage> {
  Future<void> sendcancelledmessage() async {
    final docsnap = await FirebaseFirestore.instance
        .collection('drivers')
        .doc(widget.driverid)
        .get();
    final docdata = docsnap.data();
    final token = docdata!['token'];
    PushNotificationService service = PushNotificationService();
    await service.sendNotification(token,
        title: 'Ride Cancelled',
        bodytxt: 'User has cancelled the ride',
        rideid: widget.rideid);
  }

  int _selectedContainerIndex = 0;
  String cancelledreason = 'Please select the reason for cancellation.';

  Future<void> setstatustocancel() async {
    FirebaseFirestore.instance
        .collection('RideRequest')
        .doc(widget.rideid)
        .update(({'Status': 'Cancelled'}));
    FirebaseFirestore.instance
        .collection('RideRequest')
        .doc(widget.rideid)
        .set(({'canceldueto': cancelledreason}), SetOptions(merge: true));
    if (widget.afterbooking) {
      await sendcancelledmessage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customappbar(context,
          title: 'Cancel Ride', backgroundColor: Colors.transparent),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const CustomText(
                    title: 'Please select the reason for cancellation.',
                    fontSize: 12,
                    textAlign: TextAlign.center,
                    color: Appcolors.neutralgrey,
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  _buildCheckboxContainer(
                      0, 'It takes too long to find a captain'),
                  const SizedBox(height: 30),
                  _buildCheckboxContainer(1, 'Unable to contact driver'),
                  const SizedBox(height: 30),
                  _buildCheckboxContainer(
                      2, 'Driver denied to go to destination'),
                  const SizedBox(height: 30),
                  _buildCheckboxContainer(3, 'Driver denied to come to pickup'),
                  const SizedBox(height: 30),
                  _buildCheckboxContainer(4, 'Wrong address shown'),
                  const SizedBox(height: 30),
                  _buildCheckboxContainer(5, 'The price is not reasonable'),
                  const SizedBox(height: 50),
                  Custombutton(
                    text: 'Submit',
                    fontSize: 16,
                    height: 50,
                    width: constraints.maxWidth * 0.5,
                    fontWeight: FontWeight.w500,
                    borderRadius: 8,
                    ontap: () async {
                      await setstatustocancel();
                      resetapp(context);
                      showcanceldialogue(context);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCheckboxContainer(int index, String title) {
    Color borderColor = _selectedContainerIndex == index
        ? Appcolors.primaryColor
        : Appcolors.neutralgrey;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedContainerIndex = index;
          cancelledreason = title;
        });
      },
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(
            color: borderColor,
          ),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Center(
          child: ListTile(
            leading: Checkbox(
              value: _selectedContainerIndex == index,
              onChanged: (_) {
                setState(() {
                  _selectedContainerIndex = index;
                  cancelledreason = title;
                });
              },
              activeColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
            ),
            title: CustomText(
              title: title,
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
              color: Appcolors.neutralgrey700,
            ),
          ),
        ),
      ),
    );
  }
}
