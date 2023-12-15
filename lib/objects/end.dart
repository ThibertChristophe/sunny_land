import 'dart:async';

import 'package:flame/components.dart';
import 'package:sunny_land/sunnyland.dart';

enum EndState { active, inactive }

class End extends SpriteAnimationGroupComponent<EndState>
    with HasGameRef<SunnyLand> {
  End({size, required position})
      : super(
            size: Vector2.all(21), position: position, anchor: Anchor.topLeft) {
    debugMode = true;
  }

  @override
  FutureOr<void> onLoad() async {
    animations = {
      EndState.active: await game.loadSpriteAnimation(
        'gem.png',
        SpriteAnimationData.sequenced(
          amount: 5,
          textureSize: Vector2.all(15),
          stepTime: 0.1,
        ),
      ),
      EndState.inactive: await game.loadSpriteAnimation(
        'item-feedback.png',
        SpriteAnimationData.sequenced(
          amount: 5,
          textureSize: Vector2.all(33),
          stepTime: 0.12,
          loop: false,
        ),
      ),
    };
    current = EndState.active;
    return super.onLoad();
  }
}
