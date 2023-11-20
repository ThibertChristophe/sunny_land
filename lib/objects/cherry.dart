import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/flame.dart';
import 'package:flame/sprite.dart';
import '../sunnyland.dart';

enum CherryState { idle }

class Cherry extends SpriteAnimationGroupComponent<CherryState>
    with CollisionCallbacks, HasGameRef<SunnyLand> {
  Cherry({required super.position})
      : super(size: Vector2.all(21), anchor: Anchor.bottomLeft) {
    //debugMode = true;
  }

  @override
  void onLoad() async {
    animations = {
      CherryState.idle: await game.loadSpriteAnimation(
        'cherry.png',
        SpriteAnimationData.sequenced(
          amount: 5,
          textureSize: Vector2.all(21),
          stepTime: 0.2,
        ),
      ),
    };
    final ec = ReverseLinearEffectController(1);

    current = CherryState.idle;

    add(CircleHitbox());
  }
}
