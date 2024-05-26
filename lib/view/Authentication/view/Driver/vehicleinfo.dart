import 'package:flutter/material.dart';
import 'package:ridemate/Providers/driverregprovider.dart';
import 'package:ridemate/utils/appcolors.dart';
import 'package:ridemate/view/Authentication/components/customappbar.dart';
import 'package:ridemate/routing/routing.dart';
import 'package:ridemate/view/Authentication/view/Driver/regdrlcdrcnic.dart';
import 'package:ridemate/view/Authentication/view/Driver/listtile.dart';
import 'package:ridemate/view/Authentication/view/Driver/transportname.dart';
import 'package:ridemate/view/Authentication/view/Driver/vehiclephoto.dart';
import 'package:ridemate/view/Authentication/view/Driver/vehiclereg.dart';

class Vehicleinfo<T extends Driverregprovider1> extends StatelessWidget {
  final String title;
  final String type;
  const Vehicleinfo(
      {super.key, required this.title, this.type = 'Car Registration'});

  @override
  Widget build(BuildContext context) {
    {
      return Scaffold(
        appBar: customappbar(context,
            title: title, backgroundColor: Appcolors.primaryColor),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: 20,
                left: 10,
                right: 10,
              ),
              child: Container(
                height: 370,
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
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: CustomListTile(
                          title: 'Transport Name',
                          icon: null,
                          onTap: () {
                            navigateToScreen(context,
                                transportname(title: 'Transport Name'));
                          },
                        ),
                      ),
                      const Divider(
                        thickness: 1.0,
                        color: Colors.grey,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: CustomListTile(
                          title: 'Driver Licence',
                          icon: null,
                          onTap: () {
                            navigateToScreen(
                              context,
                              Regdrlcdrcnic<T>(title: 'Driver Licence'),
                            );
                          },
                        ),
                      ),
                      const Divider(
                        thickness: 1.0,
                        color: Colors.grey,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: CustomListTile(
                          title: 'Photo of Vehicle',
                          icon: null,
                          onTap: () {
                            navigateToScreen(
                              context,
                              type == 'Moto Registration'
                                  ? const vehiclephoto<Motovehiclephoto>(
                                      title: 'Photo of Vehicle')
                                  : const vehiclephoto<Carvehiclephoto>(
                                      title: 'Photo of Vehicle'),
                            );
                          },
                        ),
                      ),
                      const Divider(
                        thickness: 1.0,
                        color: Colors.grey,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: CustomListTile(
                          title: 'Certificate of Vehicle Registration',
                          icon: null,
                          onTap: () {
                            navigateToScreen(
                              context,
                              type == 'Moto Registration'
                                  ? const Vehicleregis<Motoreg>(
                                      title: 'Vehicle Registration')
                                  : const Vehicleregis<Carreg>(
                                      title: 'Vehicle Registration'),
                            );
                          },
                        ),
                      ),
                      const Divider(
                        thickness: 1.0,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}
