import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:sunny_land/actors/enemies.dart';
import 'package:sunny_land/obstacles/ground.dart';

import '../sunnyland.dart';

enum OposumDirection { left, right, none }

//enum OposumState { idle, jump, fall, death }

class Oposum extends SpriteAnimationGroupComponent<EnemyState>
    with Enemies, CollisionCallbacks, HasGameRef<SunnyLand> {
  Oposum({required super.position})
      : super(size: Vector2.all(30), anchor: Anchor.center) {
    //debugMode = true;
  }

  // bool dead = false;
  //Vector2 velocity = Vector2(0, 0);

  double gravity = 1.5;
  double moveSpeed = 50;
  OposumDirection horizontalDirection = OposumDirection.none;
  bool onGround = false;

  late Timer interval;

  @override
  void onLoad() async {
    animations = {
      EnemyState.idle: await game.loadSpriteAnimation(
        'oposum.png',
        SpriteAnimationData.sequenced(
          amount: 6,
          textureSize: Vector2(36, 28),
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
      4,
      onTick: () => moveSpeed = -1 * moveSpeed,
      repeat: true,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!dead) {
      interval.update(dt);
      // Gravité
      if (!onGround) {
        velocity.y += gravity;
        position.y += velocity.y * dt;
      }
      if (onGround) {
        current = EnemyState.idle;
      }
      velocity.x = moveSpeed;
      if (moveSpeed > 0) {
        horizontalDirection = OposumDirection.left;
      } else {
        horizontalDirection = OposumDirection.right;
      }

      if (horizontalDirection == OposumDirection.left && scale.x > 0) {
        flipHorizontally();
      } else if (horizontalDirection == OposumDirection.right && scale.x < 0) {
        flipHorizontally();
      }
      onGround = false;
      position += velocity * dt;
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);

    // On stop notre chute quand on est sur du Ground
    if (other is Ground) {
      if (intersectionPoints.length == 2) {
        final mid = (intersectionPoints.elementAt(0) +
                intersectionPoints.elementAt(1)) /
            2;

        final collisionVector = absoluteCenter - mid;
        double penetrationDepth = (size.x / 2) - collisionVector.length;

        collisionVector.normalize();

        position += collisionVector.scaled(penetrationDepth);
        velocity.y = 0;
        onGround = true;
      }
    }
  }

  void die() {
    current = EnemyState.death;
    dead = true;
    add(RemoveEffect(delay: 0.6));
  }
}
