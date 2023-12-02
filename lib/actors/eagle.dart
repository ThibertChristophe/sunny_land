import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:sunny_land/actors/enemies.dart';

import '../sunnyland.dart';

//enum EagleState { idle, jump, fall, death }

class Eagle extends SpriteAnimationGroupComponent<EnemyState>
    with Enemies, CollisionCallbacks, HasGameRef<SunnyLand> {
  Eagle({required super.position})
      : super(size: Vector2.all(40), anchor: Anchor.center) {
    //debugMode = true;
  }

  //bool dead = false;
  //Vector2 velocity = Vector2(0, 0);

  double moveSpeed = 30;
  late Timer interval;

  @override
  void onLoad() async {
    animations = {
      EnemyState.idle: await game.loadSpriteAnimation(
        'eagle-attack.png',
        SpriteAnimationData.sequenced(
          amount: 4,
          textureSize: Vector2.all(40),
          stepTime: 0.25,
        ),
      ),
      EnemyState.death: await game.loadSpriteAnimation(
        'enemy-deadth.png',
        SpriteAnimationData.sequenced(
          amount: 6,
          textureSize: Vector2(40, 41),
          stepTime: 0.1,
          loop: false,
        ),
      ),
    };
    current = EnemyState.idle;

    add(CircleHitbox());

    interval = Timer(
      3,
      onTick: () => moveSpeed = -1 * moveSpeed,
      repeat: true,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!dead) {
      interval.update(dt);
      velocity.y = moveSpeed;

      position += velocity * dt;
    }
  }

  void die() {
    current = EnemyState.death;
    dead = true;
    add(RemoveEffect(delay: 0.6));
  }
}
