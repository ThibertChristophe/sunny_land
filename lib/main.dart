import 'package:flame/game.dart';
import 'package:flutter/widgets.dart';
import 'package:sunny_land/sunnyland.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    const GameWidget<SunnyLand>.controlled(
      gameFactory: SunnyLand.new,
    ),
  );
}
