import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:sunny_land/actors/enemies.dart';
import 'package:sunny_land/obstacles/ground.dart';

import '../sunnyland.dart';

enum FrogDirection { left, right, none }

//enum FrogState { idle, jump, fall, death }

class Frog extends SpriteAnimationGroupComponent<EnemyState>
    with Enemies, CollisionCallbacks, HasGameRef<SunnyLand> {
  Frog({required super.position})
      : super(size: Vector2.all(32), anchor: Anchor.center) {
    // debugMode = true;
  }
  late Timer interval;

  //bool dead = false;
  //Vector2 velocity = Vector2(0, 0);

  double gravity = 1.5;
  double moveSpeed = 200;
  FrogDirection horizontalDirection = FrogDirection.none;
  bool onGround = false;
  bool hasJumped = false;
  final double _jumpLength = 50;
  int nbJump = 0;

  @override
  void onLoad() async {
    animations = {
      EnemyState.idle: await game.loadSpriteAnimation(
        'frog-idle2.png',
        SpriteAnimationData.sequenced(
          amount: 4,
          textureSize: Vector2(35, 27),
          stepTime: 0.5,
        ),
      ),
      EnemyState.death: await game.loadSpriteAnimation(
        'enemy-deadth.png',
        SpriteAnimationData.sequenced(
          amount: 6,
          textureSize: Vector2(40, 41),
          stepTime: 0.2,
          loop: false,
        ),
      ),
      EnemyState.jump: SpriteAnimation.spriteList(
        [await game.loadSprite('frog-up.png')],
        stepTime: double.infinity,
      ),
      EnemyState.fall: SpriteAnimation.spriteList(
        [await game.loadSprite('frog-down.png')],
        stepTime: double.infinity,
      ),
    };
    current = EnemyState.idle;

    add(CircleHitbox());

    interval = Timer(
      6,
      onTick: () => jump(),
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
      } else if (velocity.y > 5) {
        current = EnemyState.fall;
      }
      if (horizontalDirection == FrogDirection.left && scale.x > 0) {
        flipHorizontally();
      } else if (horizontalDirection == FrogDirection.right && scale.x < 0) {
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
        velocity.x = 0;
        onGround = true;
      }
    }
  }

  void die() {
    current = EnemyState.death;
    dead = true;
    add(RemoveEffect(delay: 1.0));
  }

  void jump() {
    current = EnemyState.jump;
    onGround = false;

    velocity.y -= _jumpLength;
    if (nbJump % 3 == 0) {
      velocity.x -= 50;
      horizontalDirection = FrogDirection.right;
    } else {
      velocity.x += 50;
      horizontalDirection = FrogDirection.left;
    }
    nbJump++;
  }
}
