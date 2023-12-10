import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:sunny_land/main_menu.dart';
import 'package:sunny_land/sunnyland.dart';

void main() {
  runApp(
    GameWidget<SunnyLand>.controlled(
      gameFactory: SunnyLand.new,
      overlayBuilderMap: {
        'MainMenu': (_, game) => MainMenu(game: game),
      },
      initialActiveOverlays: const ['MainMenu'],
    ),
  );
}
