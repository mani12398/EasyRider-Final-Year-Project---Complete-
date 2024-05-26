import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:ridemate/widgets/customtext.dart';

import '../../../../fluttercameraoverlay/flutter_camera_overlay.dart';
import '../../../../fluttercameraoverlay/model.dart';

class OverlayCamera extends StatelessWidget {
  const OverlayCamera({super.key, required this.onpressed, required this.type});
  final Function onpressed;
  final String type;
  final OverlayFormat format = OverlayFormat.cardID1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<List<CameraDescription>?>(
        future: availableCameras(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data == null) {
              return const Align(
                  alignment: Alignment.center,
                  child: CustomText(
                    title: 'No camera found',
                    color: Colors.black,
                  ));
            }
            return CameraOverlay(
              snapshot.data!.first,
              CardOverlay.byFormat(format),
              (XFile file) => showDialog(
                context: context,
                barrierColor: Colors.black,
                builder: (context) {
                  CardOverlay overlay = CardOverlay.byFormat(format);
                  return AlertDialog(
                      actionsAlignment: MainAxisAlignment.center,
                      backgroundColor: Colors.black,
                      title: const CustomText(
                        title: 'Capture Result',
                        color: Colors.white,
                        fontSize: 15,
                        textAlign: TextAlign.center,
                      ),
                      actions: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            OutlinedButton(
                                onPressed: () {
                                  Navigator.of(context)
                                    ..pop()
                                    ..pop();
                                  onpressed(file.path);
                                },
                                child: const Icon(Icons.check)),
                            OutlinedButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Icon(Icons.close)),
                          ],
                        ),
                      ],
                      content: SizedBox(
                          width: double.infinity,
                          child: AspectRatio(
                            aspectRatio: overlay.ratio!,
                            child: Container(
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                fit: BoxFit.fitWidth,
                                alignment: FractionalOffset.center,
                                image: FileImage(File(file.path)),
                              )),
                            ),
                          )));
                },
              ),
              info: type == 'Driver Licence'
                  ? 'Position your driving licence within the rectangle and ensure the image is perfectly readable.'
                  : 'Position your ID card within the rectangle and ensure the image is perfectly readable.',
              label: type == 'Driver Licence' ? 'Driving licence' : 'ID Card',
            );
          } else {
            return const Align(
                alignment: Alignment.center,
                child: CustomText(
                  title: 'Fetching Cameras',
                  color: Colors.black,
                ));
          }
        },
      ),
    );
  }
}
