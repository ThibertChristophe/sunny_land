import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sunny_land/sunnyland.dart';

class MainMenu extends StatelessWidget {
  // Reference to parent game.
  final SunnyLand game;

  const MainMenu({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    game.pauseEngine();
    const blackTextColor = Color.fromRGBO(0, 0, 0, 1.0);
    const whiteTextColor = Color.fromRGBO(255, 255, 255, 1.0);

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
                color: Colors.red,
                image: DecorationImage(
                    image: AssetImage('images/menu.png'), fit: BoxFit.cover)),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 400,
                  child: Image(
                      image: AssetImage('images/titre.png'), fit: BoxFit.cover),
                ).animate().scale(),
                const SizedBox(height: 50),
                SizedBox(
                  width: 120,
                  child: InkWell(
                    onTap: () {
                      game.resumeEngine();
                      game.overlays.remove('MainMenu');
                    },
                    child: const Image(
                      image: AssetImage('images/playy.png'),
                      fit: BoxFit.cover,
                    )
                        .animate(
                            onPlay: (controller) => controller.repeat(),
                            delay: 500.ms)
                        .fadeIn(delay: 400.ms)
                        .then(delay: 200.ms)
                        .fadeOut(delay: 400.ms),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
