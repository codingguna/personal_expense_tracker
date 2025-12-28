// lib/ui/widgets/gradient_header.dart
import 'package:flutter/material.dart';

class GradientHeader extends StatelessWidget {
  final String title;

  const GradientHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2F8F83), Color(0xFF3AAFA9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      alignment: Alignment.topCenter,
      padding: const EdgeInsets.only(top: 60),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
