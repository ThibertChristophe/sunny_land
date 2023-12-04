import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:sunny_land/sunnyland.dart';

class Ground extends PositionComponent with HasGameRef<SunnyLand> {
  Ground({required size, required position})
      : super(size: size, position: position) {
    //debugMode = true;
  }
  // bool isWall = false;

  //@override
  // void update(double dt) {
  //   super.update(dt);

  //   if (position.y == (game.fox.position.y - game.size.y)) {
  //     isWall = true;
  //   } else {
  //     isWall = false;
  //   }
  // }

  @override
  FutureOr<void> onLoad() {
    add(RectangleHitbox());
    return super.onLoad();
  }
}
