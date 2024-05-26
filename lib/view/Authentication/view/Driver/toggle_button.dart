// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class ToggleSwitch extends StatefulWidget {
  final Function(bool value) onChanged;
  final bool initialValue;

  // ignore: prefer_const_constructors_in_immutables, use_key_in_widget_constructors
  ToggleSwitch({required this.onChanged, required this.initialValue});

  @override
  // ignore: library_private_types_in_public_api
  _ToggleSwitchState createState() => _ToggleSwitchState();
}

class _ToggleSwitchState extends State<ToggleSwitch> {
  late bool _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _value = !_value;
        widget.onChanged(_value);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: _value ? Colors.green : Colors.red,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _value ? "Online" : "Offline",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 8),
            Container(
              width: 25,
              height: 25,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: CircleAvatar(
                  backgroundColor: _value ? Colors.green : Colors.red,
                  radius: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
