import 'package:flutter/material.dart';

class CustomListTile extends StatelessWidget {
  final String title;
  final IconData? icon; // Make the icon parameter optional
  final Function onTap;

  const CustomListTile({
    super.key,
    required this.title,
    this.icon, // Make the icon optional
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap();
      },
      child: Container(
        color: Colors.transparent,
        child: ListTile(
          leading: icon != null // Check if an icon is provided
              ? Icon(
                  icon,
                  size: 35,
                  color: Colors.black,
                )
              : null, // If no icon is provided, don't show the leading icon
          title: Text(
            title,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          trailing: const Icon(
            Icons.arrow_forward,
            color: Colors.black,
          ),
          onTap: () {
            onTap();
          },
        ),
      ),
    );
  }
}
