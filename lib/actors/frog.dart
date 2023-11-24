import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:sunny_land/obstacles/ground.dart';

import '../sunnyland.dart';

enum FrogDirection { left, right, none }

enum FrogState { idle, jump }

class Frog extends SpriteAnimationGroupComponent<FrogState>
    with CollisionCallbacks, HasGameRef<SunnyLand> {
  Frog({required super.position})
      : super(size: Vector2.all(32), anchor: Anchor.center) {
    debugMode = true;
  }
  late Timer interval;

  double gravity = 1.5;
  Vector2 velocity = Vector2(0, 0);
  double moveSpeed = 200;
  FrogDirection horizontalDirection = FrogDirection.none;
  bool onGround = false;
  bool hasJumped = false;
  final double _jumpLength = 50;
  int nbJump = 0;

  @override
  void onLoad() async {
    animations = {
      FrogState.idle: await game.loadSpriteAnimation(
        'frog-idle2.png',
        SpriteAnimationData.sequenced(
          amount: 4,
          textureSize: Vector2(35, 27),
          stepTime: 0.5,
        ),
      ),
      FrogState.jump: await game.loadSpriteAnimation(
        'frog-jump2.png',
        SpriteAnimationData.sequenced(
          amount: 1,
          textureSize: Vector2(35, 32),
          stepTime: 1,
        ),
      ),
    };
    current = FrogState.idle;

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
    interval.update(dt);
    // Gravité
    if (!onGround) {
      velocity.y += gravity;
      position.y += velocity.y * dt;
    }
    if (onGround) {
      current = FrogState.idle;
    }
    if (horizontalDirection == FrogDirection.left && scale.x > 0) {
      flipHorizontally();
    } else if (horizontalDirection == FrogDirection.right && scale.x < 0) {
      flipHorizontally();
    }
    onGround = false;
    position += velocity * dt;
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

  void jump() {
    current = FrogState.jump;
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
