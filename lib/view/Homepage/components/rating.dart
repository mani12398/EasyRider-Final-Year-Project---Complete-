// ignore_for_file: library_private_types_in_public_api

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_stars/flutter_rating_stars.dart';
import 'package:ridemate/utils/appcolors.dart';
import 'package:ridemate/widgets/custombutton.dart';
import 'package:ridemate/widgets/customtext.dart';

void showratingdialogue(String driverid, BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => RatingDialog(
      driverid: driverid,
    ),
  );
}

class RatingDialog extends StatefulWidget {
  final String driverid;
  const RatingDialog({super.key, required this.driverid});

  @override
  _RatingDialogState createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  int? ratingValue;

  Future<void> savedriverrating(BuildContext context) async {
    final docref =
        FirebaseFirestore.instance.collection('drivers').doc(widget.driverid);
    final docsnap = await docref.get();
    final docdata = docsnap.data();
    if (docdata!.containsKey('driverating')) {
      double previousrating = docdata['driverating'];
      double newrating = (previousrating + ratingValue!) / 2;
      docref.update(({'driverating': newrating}));
    } else {
      docref.set(
          ({'driverating': ratingValue!.toDouble()}), SetOptions(merge: true));
    }
  }

  @override
  Widget build(BuildContext context) {
    Color textColor = Colors.black;

    if (ratingValue != null) {
      switch (ratingValue) {
        case 1:
        case 2:
        case 3:
          textColor = Colors.red;
          break;
        case 4:
          textColor = Colors.orange;
          break;
        case 5:
          textColor = Colors.green;
          break;
        default:
          textColor = Colors.black;
      }
    }

    return AlertDialog(
      content: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.transparent,
            width: 2.0,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/personimage.jpg'),
            ),
            const SizedBox(height: 16),
            const CustomText(
              title: 'We value your input. Please rate your driving experience',
              fontSize: 16,
              fontWeight: FontWeight.w100,
              textAlign: TextAlign.center,
              color: Appcolors.contentPrimary,
            ),
            const SizedBox(height: 16),
            RatingStars(
              value: ratingValue?.toDouble() ?? 0,
              onValueChanged: (value) {
                setState(() {
                  ratingValue = value.toInt();
                });
              },
              starBuilder: (index, color) => Icon(
                Icons.star,
                color: color,
              ),
              starCount: 5,
              starSize: 40,
              valueLabelColor: const Color(0xff9b9b9b),
              valueLabelTextStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w400,
                fontStyle: FontStyle.normal,
                fontSize: 12.0,
              ),
              valueLabelRadius: 10,
              maxValue: 5,
              starSpacing: 2,
              maxValueVisibility: true,
              valueLabelVisibility: false,
              animationDuration: const Duration(milliseconds: 1000),
              valueLabelPadding:
                  const EdgeInsets.symmetric(vertical: 1, horizontal: 8),
              valueLabelMargin: const EdgeInsets.only(right: 8),
              starOffColor: const Color(0xffe7e8ea),
              starColor: Appcolors.primaryColor,
            ),
            if (ratingValue != null)
              CustomText(
                title: ' ${_getRatingLabel(ratingValue!)}',
                fontSize: 14,
                fontWeight: FontWeight.w900,
                textAlign: TextAlign.center,
                color: textColor,
              ),
            const SizedBox(height: 16),
            Custombutton(
              text: 'Submit',
              height: 50,
              width: 150,
              fontSize: 22,
              fontWeight: FontWeight.w500,
              borderRadius: 8,
              ontap: () async {
                Navigator.pop(context);
                await savedriverrating(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  String _getRatingLabel(int rating) {
    switch (rating) {
      case 1:
        return 'Bad';
      case 2:
        return 'Below Average';
      case 3:
        return 'Average';
      case 4:
        return 'Good';
      case 5:
        return 'Excellent';
      default:
        return '';
    }
  }
}
