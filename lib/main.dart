import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sunny_land/main_menu.dart';
import 'package:sunny_land/pause_menu.dart';
import 'package:sunny_land/sunnyland.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(
    GameWidget<SunnyLand>.controlled(
      gameFactory: SunnyLand.new,
      overlayBuilderMap: {
        'MainMenu': (_, game) => MainMenu(game: game),
        'PauseMenu': (_, game) => PauseMenu(game: game),
      },
      initialActiveOverlays: const ['MainMenu'],
    ),
  );
}
