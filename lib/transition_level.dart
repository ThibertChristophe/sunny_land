import 'package:flutter/material.dart';
import 'package:sunny_land/sunnyland.dart';

class TransitionLevel extends StatelessWidget {
  final SunnyLand game;
  const TransitionLevel({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(color: Colors.red),
        child: const Text("Transition"),
      ),
    );
  }
}
