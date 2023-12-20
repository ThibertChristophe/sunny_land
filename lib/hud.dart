import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:sunny_land/sunnyland.dart';

class Hud extends PositionComponent with HasGameRef<SunnyLand> {
  Hud({
    super.position,
    super.size,
    super.scale,
    super.angle,
    super.anchor,
    super.children,
    super.priority = 5,
  });

  late TextComponent _scoreTextComponent;
  late TextComponent _levelTextComponent;

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
      position: Vector2(game.size.x - 100, 35),
    );
    add(_scoreTextComponent);

    final gemSprite = await game.loadSprite('gem-5.png');

    add(
      SpriteComponent(
        sprite: gemSprite,
        position: Vector2(game.size.x - 130, 35),
        size: Vector2.all(20),
        anchor: Anchor.center,
      ),
    );

    _levelTextComponent = TextComponent(
      text: '${game.currentLevelIndex}',
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 26,
          color: Color.fromRGBO(10, 10, 10, 1),
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(100, 35),
    );
    add(_levelTextComponent);
  }

  @override
  void update(double dt) {
    _scoreTextComponent.text = '${game.gemsCollected}';
  }
}
