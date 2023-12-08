import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:sunny_land/sunnyland.dart';

// On doit pouvoir passer à travers en venant du dessous
class Platform extends PositionComponent with HasGameRef<SunnyLand> {
  Platform({required size, required position})
      : super(size: size, position: position) {
    debugMode = true;
  }

  bool active = false; //s'active et desactive

  @override
  void update(double dt) {
    super.update(dt);
    // Detecte si le joueur est au dessus de la plate forme
    // Si il est au dessus alors on active

    if (game.fox.y + (game.fox.height / 2) < position.y) {
      active = true;
    } else {
      active = false;
    }
  }

  @override
  FutureOr<void> onLoad() {
    add(RectangleHitbox());
    return super.onLoad();
  }
}
