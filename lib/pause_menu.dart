import 'package:sunny_land/sunnyland.dart';
import 'package:flutter/material.dart';

class PauseMenu extends StatelessWidget {
  final SunnyLand game;
  const PauseMenu({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
      ),
      child: Center(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: const Color(0xff312341),
          ),
          padding: const EdgeInsets.all(20),
          width: 500,
          height: 300,
          child: Center(
            child: Column(
              children: [
                const Center(
                  child: Text(
                    "Pause",
                    style: TextStyle(fontSize: 40),
                  ),
                ),
                const SizedBox(
                  height: 25,
                ),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          TextButton(
                            style: TextButton.styleFrom(
                                fixedSize: const Size(200, 100),
                                foregroundColor: Colors.red,
                                backgroundColor: const Color(0xffffba00),
                                textStyle: const TextStyle(
                                    fontSize: 25, fontWeight: FontWeight.bold)),
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
                            style: TextButton.styleFrom(
                                fixedSize: const Size(200, 100),
                                foregroundColor: Colors.red,
                                backgroundColor: const Color(0xffffba00),
                                textStyle: const TextStyle(
                                    fontSize: 25, fontWeight: FontWeight.bold)),
                            onPressed: () {},
                            child: const Text("Quitter"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
