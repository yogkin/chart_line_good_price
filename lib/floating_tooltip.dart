import 'package:flutter/material.dart';

class PriceOverlay extends StatelessWidget {
  PriceOverlay();

  @override
  Widget build(BuildContext context) {
    return  Container(
      width: 12,
      height: 12,
      transform: Matrix4.rotationZ(0.785398), // 45 degrees in radians
      decoration: BoxDecoration(
        color: Colors.black,
      ),
    );
  }
}
