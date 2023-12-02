import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:sunny_land/sunnyland.dart';

enum CherryState { idle, hit }

class Cherry extends SpriteAnimationGroupComponent<CherryState>
    with HasGameRef<SunnyLand> {
  Cherry({size, required position})
      : super(
            size: Vector2.all(21), position: position, anchor: Anchor.topLeft) {
    //debugMode = true;
  }

  @override
  FutureOr<void> onLoad() async {
    animations = {
      CherryState.idle: await game.loadSpriteAnimation(
        'cherry.png',
        SpriteAnimationData.sequenced(
          amount: 5,
          textureSize: Vector2.all(21),
          stepTime: 0.22,
        ),
      ),
      CherryState.hit: await game.loadSpriteAnimation(
        'item-feedback.png',
        SpriteAnimationData.sequenced(
          amount: 5,
          textureSize: Vector2.all(33),
          stepTime: 0.15,
          loop: false,
        ),
      ),
    };
    current = CherryState.idle;
    add(CircleHitbox());
    return super.onLoad();
  }

  void hitted() {
    current = CherryState.hit;
    add(RemoveEffect(delay: 0.75));
  }
}
