import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:sunny_land/sunnyland.dart';

class Hud extends PositionComponent with HasGameRef<SunnyLand> {
  Hud({
    anchor,
    super.priority = 10,
  });

  late TextComponent _scoreTextComponent;

  @override
  Future<void> onLoad() async {
    _scoreTextComponent = TextComponent(
      text: '${game.gemsCollected}',
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 26,
          color: Color.fromRGBO(10, 10, 10, 1),
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(game.size.x - 60, 35),
    );
    add(_scoreTextComponent);

    final gemSprite = await game.loadSprite('gem-5.png');

    add(
      SpriteComponent(
        sprite: gemSprite,
        position: Vector2(game.size.x - 100, 35),
        size: Vector2.all(20),
        anchor: Anchor.center,
      ),
    );
  }

  @override
  void update(double dt) {
    _scoreTextComponent.text = '${game.gemsCollected}';
  }
}
