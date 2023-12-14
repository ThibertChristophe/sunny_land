import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:sunny_land/objects/cherry.dart';
import 'package:sunny_land/sunnyland.dart';

class Door extends SpriteAnimationGroupComponent<CherryState>
    with HasGameRef<SunnyLand> {
  Door({size, required position})
      : super(
            size: Vector2.all(21), position: position, anchor: Anchor.topLeft) {
    debugMode = true;
  }

  @override
  FutureOr<void> onLoad() async {
    add(RectangleHitbox());
    return super.onLoad();
  }
}
