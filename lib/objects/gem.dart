import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:sunny_land/sunnyland.dart';

enum GemState { idle, hit }

class Gem extends SpriteAnimationGroupComponent<GemState>
    with HasGameRef<SunnyLand> {
  Gem({size, required position})
      : super(
            size: Vector2.all(15),
            position: position,
            anchor: Anchor.topCenter) {
    // debugMode = true;
  }

  @override
  FutureOr<void> onLoad() async {
    animations = {
      GemState.idle: await game.loadSpriteAnimation(
        'gem.png',
        SpriteAnimationData.sequenced(
          amount: 5,
          textureSize: Vector2.all(15),
          stepTime: 0.1,
        ),
      ),
      GemState.hit: await game.loadSpriteAnimation(
        'item-feedback.png',
        SpriteAnimationData.sequenced(
          amount: 5,
          textureSize: Vector2.all(33),
          stepTime: 0.12,
          loop: false,
        ),
      ),
    };
    current = GemState.idle;
    add(CircleHitbox());
    return super.onLoad();
  }

  void hitted() {
    current = GemState.hit;
    add(RemoveEffect(
      delay: 0.75,
      onComplete: () => game.gemsCollected += 1,
    ));
  }
}
