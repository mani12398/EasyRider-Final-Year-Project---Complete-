import 'package:flutter/material.dart';
import 'package:ridemate/routing/routing.dart';
import 'package:ridemate/utils/appcolors.dart';
import 'package:ridemate/view/Authentication/view/Driver/transport.dart';
import 'package:ridemate/view/Authentication/view/Driver/listtile.dart';

import '../../components/customappbar.dart';

class GoingtoWorkAs extends StatelessWidget {
  const GoingtoWorkAs({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customappbar(context,
          title: 'Driver Registration',
          backgroundColor: Appcolors.primaryColor),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
        child: Container(
          height: 160,
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
          padding: const EdgeInsets.only(top: 10),
          child: Column(
            children: [
              CustomListTile(
                title: 'Car',
                icon: Icons.car_rental_rounded,
                onTap: () {
                  navigateToScreen(
                      context, const Transport(title: 'Car Registration'));
                },
              ),
              const Divider(
                thickness: 1.0,
                color: Colors.grey,
              ),
              CustomListTile(
                title: 'Moto',
                icon: Icons.motorcycle_rounded,
                onTap: () {
                  navigateToScreen(
                      context, const Transport(title: 'Moto Registration'));
                },
              ),
              const Divider(
                thickness: 1.0,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
