import 'package:sunny_land/sunnyland.dart';
import 'package:flutter/material.dart';

class PauseMenu extends StatelessWidget {
  final SunnyLand game;
  const PauseMenu({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        width: 500,
        height: 300,
        color: Colors.red,
        child: Center(
          child: SizedBox(
            width: 200,
            child: Column(
              children: [
                const Center(
                  child: Text("Pause"),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        game.resumeEngine();
                        game.overlays.remove('PauseMenu');
                      },
                      child: const Text("Reprendre"),
                    ),
                    const SizedBox(
                      width: 25,
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text("Quitter"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
