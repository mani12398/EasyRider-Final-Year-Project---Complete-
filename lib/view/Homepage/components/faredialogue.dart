import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ridemate/Providers/homeprovider.dart';
import 'package:ridemate/utils/appcolors.dart';
import 'package:ridemate/widgets/customtext.dart';

void showFareDialog(BuildContext context, double actualFare) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      double sliderValue = 2;
      double fare = actualFare;

      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: Appcolors.primary100,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
            ),
            title: const CustomText(
              title: 'Set your fare',
              textAlign: TextAlign.center,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Appcolors.contentTertiary,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: CustomText(
                    title: 'Fare: ${fare.toStringAsFixed(0)} PKR',
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Appcolors.contentTertiary,
                  ),
                ),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: Appcolors.contentTertiary,
                    inactiveTrackColor: Colors.blue.withOpacity(0.3),
                    thumbColor: Appcolors.contentTertiary,
                    overlayColor: Colors.blue.withOpacity(0.2),
                    valueIndicatorColor: Appcolors.contentTertiary,
                    valueIndicatorTextStyle: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  child: Slider(
                    value: sliderValue,
                    min: 0,
                    max: 2,
                    divisions: 2,
                    label: sliderValue == 0
                        ? 'Minus 15%'
                        : sliderValue == 1
                            ? 'Minus 10%'
                            : 'Actualfare',
                    onChanged: (value) {
                      setState(() {
                        sliderValue = value;
                        if (sliderValue == 0) {
                          fare = actualFare - (actualFare * 0.15);
                        } else if (sliderValue == 1) {
                          fare = actualFare - (actualFare * 0.07);
                        } else if (sliderValue == 2) {
                          fare = actualFare;
                        }
                      });
                    },
                  ),
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: const CustomText(
                  title: 'OK',
                  fontSize: 18,
                  color: Appcolors.contentTertiary,
                ),
                onPressed: () {
                  Provider.of<Homeprovider>(context, listen: false)
                      .userselectedfare(fare.truncate());
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    },
  );
}
