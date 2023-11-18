import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:sunny_land/sunnyland.dart';

class Platform extends PositionComponent with HasGameRef<SunnyLand> {
  Platform({required size, required position})
      : super(size: size, position: position) {
    debugMode = true;
  }
  bool active = false;

  @override
  void update(double dt) {
    super.update(dt);

    if (game.fox.y + 15 < position.y) {
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
