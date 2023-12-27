import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:sunny_land/sunnyland.dart';

class PauseButton extends SpriteComponent
    with HasGameRef<SunnyLand>, TapCallbacks {
  PauseButton({size, required position})
      : super(size: size, position: position, anchor: Anchor.center) {
    //debugMode = true;
  }
  @override
  FutureOr<void> onLoad() async {
    sprite = await game.loadSprite('pause.png');
    return super.onLoad();
  }

  @override
  void onTapUp(TapUpEvent event) async {
    super.onTapUp(event);
    if (game.overlays.isActive('PauseMenu')) {
      game.overlays.remove('PauseMenu');
      game.resumeEngine();
    } else {
      game.overlays.add('PauseMenu');
      game.pauseEngine();
    }
  }
}
