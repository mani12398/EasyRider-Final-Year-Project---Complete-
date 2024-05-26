import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ridemate/Providers/driverregprovider.dart';
import 'package:ridemate/utils/appcolors.dart';
import 'package:ridemate/view/Authentication/components/customappbar.dart';
import 'package:ridemate/widgets/custombutton.dart';

import '../../../../Providers/userdataprovider.dart';
import '../../../Dialogueboxes/errordialogue.dart';

// ignore: camel_case_types
class Selfiewithid<T extends Driverregprovider2> extends StatelessWidget {
  final String title;
  const Selfiewithid({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final myprovider = Provider.of<T>(context, listen: false);
    return Scaffold(
      appBar: customappbar(context,
          title: title, backgroundColor: Appcolors.primaryColor),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.only(
            top: 20,
            left: 10,
            right: 10,
          ),
          child: Container(
            height: 350,
            width: 450,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 3,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.only(
                    top: 15,
                  ),
                  child: Text(
                    "ID Confirmation",
                    style: TextStyle(
                      // Making text bold
                      color: Colors.black, // Changing text color
                      fontSize: 18, // Changing text size
                    ),
                  ),
                ),
                Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(
                        top: 50,
                      ),
                    ),
                    Center(
                      child: Consumer<T>(
                        builder: (context, value, child) => CircleAvatar(
                            backgroundColor: Appcolors.neutralgrey200,
                            radius: 70,
                            backgroundImage: value.image != null
                                ? Image.file(
                                    value.image!,
                                    fit: BoxFit.cover,
                                  ).image
                                : null),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 50),
                      child: Custombutton(
                          text: 'Add a Photo',
                          height: 40,
                          width: 200,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          borderRadius: 8,
                          ontap: () => myprovider.updateimage()),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Padding(
            padding: const EdgeInsets.only(top: 50),
            child: Consumer<T>(
              builder: (context, value, child) => Custombutton(
                  text: 'Done',
                  loading: value.loading,
                  height: 60,
                  width: 300,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  borderRadius: 8,
                  ontap: () {
                    if (value.checkisempty()) {
                      errordialogue(context);
                    } else {
                      String userid =
                          Provider.of<Userdataprovider>(context, listen: false)
                              .userId;

                      value.saveImage(userid, title, context);
                    }
                  }),
            )),
      ]),
    );
  }
}
