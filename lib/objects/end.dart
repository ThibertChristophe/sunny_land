import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:sunny_land/sunnyland.dart';

class EndButton extends SpriteComponent
    with TapCallbacks, HasVisibility, HasGameRef<SunnyLand> {
  EndButton({size, required position})
      : super(size: size, position: position, anchor: Anchor.topLeft) {
    //   debugMode = true;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (game.fox.x >= x && game.fox.x <= x + width) {
      isVisible = true;
    } else {
      isVisible = false;
    }
  }

  @override
  FutureOr<void> onLoad() async {
    sprite = await game.loadSprite('touch.png');
    isVisible = false;
    add(RectangleHitbox());
    return super.onLoad();
  }

  @override
  void onTapUp(TapUpEvent event) async {
    game.overlays.add("TransitionLevel");
    game.pauseEngine();
    game.loadNextLevel();
    Future.delayed(const Duration(milliseconds: 2000), () {
      game.overlays.remove("TransitionLevel");
      game.resumeEngine();
    });
    super.onTapUp(event);
  }
}
