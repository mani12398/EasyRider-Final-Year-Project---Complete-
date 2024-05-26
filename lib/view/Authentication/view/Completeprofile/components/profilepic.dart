import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:ridemate/utils/appcolors.dart';
import 'package:ridemate/utils/appimages.dart';

import '../../../../../Providers/completeprofileprovider.dart';

class Profilepic extends StatelessWidget {
  const Profilepic({super.key});

  @override
  Widget build(BuildContext context) {
    final myprovider =
        Provider.of<Completeprofileprovider>(context, listen: false);
    return Center(
      child: Stack(
        children: [
          Consumer<Completeprofileprovider>(
            builder: (context, pic, child) => CircleAvatar(
              backgroundColor: Appcolors.neutralgrey200,
              backgroundImage: pic.image == null
                  ? const AssetImage('assets/personimage.jpg')
                  : Image.file(
                      pic.image!,
                      fit: BoxFit.cover,
                    ).image,
              radius: 50,
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: myprovider.uploadImage,
              child: Image.asset(
                AppImages.camerapic,
                height: 26.h,
                width: 26.w,
              ),
            ),
          )
        ],
      ),
    );
  }
}
