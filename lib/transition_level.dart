import 'package:flutter/material.dart';
import 'package:sunny_land/sunnyland.dart';

class TransitionLevel extends StatelessWidget {
  final SunnyLand game;
  const TransitionLevel({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(color: Colors.red),
      child: Center(
        child: SizedBox(
          width: 400,
          height: 350,
          child: Column(
            children: [
              const Image(
                fit: BoxFit.fill,
                image: AssetImage('assets/images/big level.png'),
              ),
              SizedBox(
                width: 200,
                height: 200,
                child: Image(
                  fit: BoxFit.fill,
                  image: AssetImage(
                      'assets/images/${game.currentLevelIndex + 1}.png'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
