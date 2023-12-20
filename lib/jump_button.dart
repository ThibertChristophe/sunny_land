import 'dart:async';

import 'package:flame/flame.dart';
import 'package:flame/components.dart';
import 'package:sunny_land/sunnyland.dart';
import 'package:flame/events.dart';

class JumpButton extends SpriteComponent
    with HasGameRef<SunnyLand>, TapCallbacks {
  JumpButton();
  @override
  FutureOr<void> onLoad() async {
    sprite = Sprite(await Flame.images.load('jumpButton.png'));
    position = Vector2(
      game.size.x - 128 - 128,
      game.size.y - 128 - 128,
    );
    priority = 10;
    size = Vector2(128, 128);
    return super.onLoad();
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    game.fox.jump();
  }
}
