import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:sunny_land/obstacles/ground.dart';

import '../sunnyland.dart';

enum FrogDirection { left, right, none }

enum FrogState { idle, jump }

class Frog extends SpriteAnimationGroupComponent<FrogState>
    with CollisionCallbacks, HasGameRef<SunnyLand> {
  Frog({required super.position})
      : super(size: Vector2.all(27), anchor: Anchor.center) {
    debugMode = true;
  }
  double gravity = 1.5;
  Vector2 velocity = Vector2(0, 0);
  double moveSpeed = 200;
  FrogDirection horizontalDirection = FrogDirection.none;

  bool onGround = false;

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
        'frog-jump.png',
        SpriteAnimationData.sequenced(
          amount: 3,
          textureSize: Vector2(35, 27),
          stepTime: 0.5,
        ),
      ),
    };

    current = FrogState.idle;

    add(CircleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Gravité
    if (!onGround) {
      //print('NOT GROUND');
      velocity.y += gravity;
      position.y += velocity.y * dt;
    }

    if (horizontalDirection == FrogDirection.left && scale.x > 0) {
      flipHorizontally();
    } else if (horizontalDirection == FrogDirection.right && scale.x < 0) {
      flipHorizontally();
    }

    position += velocity * dt;
    onGround = false;
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

        collisionVector.normalize(); // rend le vector2(x,y) positif ou négatif

        position += collisionVector.scaled(penetrationDepth);
        velocity.y = 0;
        onGround = true;
      }
    }
  }
}
