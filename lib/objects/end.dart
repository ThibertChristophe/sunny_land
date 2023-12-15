import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:sunny_land/sunnyland.dart';

enum EndButtonState { active, inactive }

class EndButton extends SpriteAnimationGroupComponent<EndButtonState>
    with TapCallbacks, HasGameRef<SunnyLand> {
  EndButton({size, required position})
      : super(size: size, position: position, anchor: Anchor.topLeft) {
    debugMode = true;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (game.fox.x >= x && game.fox.x <= x + width) {
      current = EndButtonState.active;
    } else {
      current = EndButtonState.inactive;
    }
  }

  @override
  FutureOr<void> onLoad() async {
    animations = {
      EndButtonState.active: await game.loadSpriteAnimation(
        'gem.png',
        SpriteAnimationData.sequenced(
          amount: 5,
          textureSize: Vector2.all(15),
          stepTime: 0.1,
        ),
      ),
    };
    current = EndButtonState.inactive;
    add(RectangleHitbox());
    return super.onLoad();
  }

  @override
  void onTapUp(TapUpEvent event) {
    super.onTapUp(event);
    print("taped door");
  }
}
