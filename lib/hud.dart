import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:sunny_land/objects/pause.dart';
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

  @override
  Future<void> onLoad() async {
    // Bouton pause
    add(
      PauseButton(
        position: Vector2(game.size.x - 150, 35),
        size: Vector2.all(64),
      ),
    );
    // Gem sprite
    final gemSprite = await game.loadSprite('gem-5.png');
    add(
      SpriteComponent(
        sprite: gemSprite,
        position: Vector2(game.size.x - 75, 35),
        size: Vector2.all(35),
        anchor: Anchor.center,
      ),
    );
    // Score
    _scoreTextComponent = TextComponent(
      text: '${game.gemsCollected}',
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 35,
          color: Color.fromRGBO(10, 10, 10, 1),
          fontWeight: FontWeight.bold,
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(game.size.x - 40, 35),
    );
    add(_scoreTextComponent);

// Level Sprite
    final levelSprite = await game.loadSprite('Level.png');
    add(
      SpriteComponent(
        sprite: levelSprite,
        position: Vector2(70, 35),
        size: Vector2.all(90),
        anchor: Anchor.center,
      ),
    );

    // Level number
    final levelNumberSprite =
        await game.loadSprite('${game.currentLevelIndex + 1}.png');
    add(
      SpriteComponent(
        sprite: levelNumberSprite,
        position: Vector2(135, 35),
        size: Vector2.all(80),
        anchor: Anchor.center,
      ),
    );
  }

  @override
  void update(double dt) {
    _scoreTextComponent.text = '${game.gemsCollected}';
  }
}
