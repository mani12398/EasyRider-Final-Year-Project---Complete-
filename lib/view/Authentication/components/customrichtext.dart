import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:ridemate/utils/appcolors.dart';

// ignore: must_be_immutable
class Customrichtext extends StatelessWidget {
  List<String> texts;
  void Function()? onTap;
  Color color;
  Customrichtext({
    super.key,
    required this.texts,
    this.onTap,
    this.color = Appcolors.neutralgrey700,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
          children: List.generate(
              texts.length,
              (index) => TextSpan(
                    text: texts[index],
                    style: TextStyle(
                      color: index % 2 != 0 ? Appcolors.primaryColor : color,
                    ),
                    recognizer: onTap != null && index == 1
                        ? (TapGestureRecognizer()..onTap = onTap)
                        : null,
                  ))),
    );
  }
}
