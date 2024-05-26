import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ridemate/Providers/driverregprovider.dart';
import 'package:ridemate/utils/appcolors.dart';
import 'package:ridemate/view/Authentication/components/customappbar.dart';
import 'package:ridemate/view/Authentication/components/customtextfield.dart';
import 'package:ridemate/view/Dialogueboxes/errordialogue.dart';
import 'package:ridemate/widgets/custombutton.dart';

import '../../../../Providers/userdataprovider.dart';

// ignore: camel_case_types
class transportname extends StatelessWidget {
  final TextEditingController _controller1 = TextEditingController();
  final TextEditingController _controller2 = TextEditingController();
  final String title;
  transportname({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customappbar(context,
          title: title, backgroundColor: Appcolors.primaryColor),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: 20,
                left: 10,
                right: 10,
              ),
              child: Container(
                height: 150,
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
                        "Vehicle Name",
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
                            top: 0,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: CustomTextField(
                            controller: _controller1,
                            hintText: 'Enter Vehicle Name',
                            isNumericOnly: false,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 20,
                left: 10,
                right: 10,
              ),
              child: Container(
                height: 150,
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
                        "Vehicle Number",
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
                            top: 0,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: CustomTextField(
                            controller: _controller2,
                            hintText: 'Enter Vehicle Number',
                            isNumericOnly: false,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 50, bottom: 50),
              child: Consumer<Transportnameprovider>(
                builder: (context, value, child) => Custombutton(
                  text: 'Done',
                  loading: value.loading,
                  height: 60,
                  width: 300,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  borderRadius: 8,
                  ontap: () {
                    if (_controller1.text == '' || _controller2.text == '') {
                      errordialogue(context);
                    } else {
                      String userid =
                          Provider.of<Userdataprovider>(context, listen: false)
                              .userId;

                      value.savedetail(userid, _controller1.text,
                          _controller2.text, context);
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
