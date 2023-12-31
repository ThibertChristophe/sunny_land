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

    return Scaffold(
      body: InkWell(
        onTap: () {
          game.resumeEngine();
          game.overlays.remove('MainMenu');
        },
        child: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                  image: DecorationImage(
                image: AssetImage('assets/images/menu.png'),
                fit: BoxFit.cover,
              )),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 600,
                    child: Image(
                      image: AssetImage('assets/images/titre.png'),
                      fit: BoxFit.cover,
                    ),
                  ).animate().scale(),
                  const SizedBox(height: 50),
                  SizedBox(
                    width: 200,
                    child: const Image(
                      image: AssetImage('assets/images/playy.png'),
                      fit: BoxFit.fill,
                    )
                        .animate(
                            onPlay: (controller) => controller
                                .repeat(), // repetition de l'effet de zoom
                            delay: 500.ms)
                        .fadeIn(delay: 400.ms)
                        .then(delay: 200.ms)
                        .fadeOut(delay: 400.ms),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
