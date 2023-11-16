import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/sprite.dart';
import 'package:sunny_land/obstacles/ground.dart';
import 'package:sunny_land/obstacles/wall.dart';
import '../sunnyland.dart';

enum FoxDirection { left, right, none }

enum PlayerState {
  running,
  jumping,
  falling,
  idle,
}

class Player extends SpriteAnimationGroupComponent<PlayerState>
    with CollisionCallbacks, HasGameRef<SunnyLand> {
  Player({required super.position})
      : super(size: Vector2.all(33), anchor: Anchor.center) {
    debugMode = true;
  }
  double gravity = 1.2;
  Vector2 velocity = Vector2(0, 0);
  double moveSpeed = 200;
  FoxDirection horizontalDirection = FoxDirection.none;
  bool onGround = false;
  bool wallHited = false;
  @override
  void onLoad() async {
    animations = {
      PlayerState.running: await game.loadSpriteAnimation(
        'run.png',
        SpriteAnimationData.sequenced(
          amount: 6,
          textureSize: Vector2.all(33),
          stepTime: 0.1,
        ),
      ),
      PlayerState.jumping: await game.loadSpriteAnimation(
        'jump.png',
        SpriteAnimationData.sequenced(
          amount: 2,
          textureSize: Vector2.all(33),
          stepTime: 0.1,
        ),
      ),
      PlayerState.falling: await game.loadSpriteAnimation(
        'hitted.png',
        SpriteAnimationData.sequenced(
          amount: 2,
          textureSize: Vector2.all(33),
          stepTime: 0.1,
        ),
      ),
      PlayerState.idle: await game.loadSpriteAnimation(
        'idle.png',
        SpriteAnimationData.sequenced(
          amount: 4,
          textureSize: Vector2.all(33),
          stepTime: 0.1,
        ),
      ),
    };
    // The starting state will be that the player is running.
    current = PlayerState.idle;

    add(CircleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!onGround) {
      velocity.y += gravity;
      position.y += velocity.y * dt;
    }

    switch (horizontalDirection) {
      case FoxDirection.left:
        velocity.x = -1 * moveSpeed;
        current = PlayerState.running;
        break;
      case FoxDirection.right:
        velocity.x = 1 * moveSpeed;
        current = PlayerState.running;
        break;
      case FoxDirection.none:
        velocity.x = 0;
        current = PlayerState.idle;
        break;
      default:
        velocity.x = 0 * moveSpeed;
        current = PlayerState.idle;
        break;
    }

    if (horizontalDirection == FoxDirection.left && scale.x > 0) {
      flipHorizontally();
    } else if (horizontalDirection == FoxDirection.right && scale.x < 0) {
      flipHorizontally();
    }
    position += velocity * dt;
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is Ground) {
      velocity.y = 0;
      onGround = true;
    }

    if (other is Wall) {
      if (intersectionPoints.length == 2) {
        final mid = (intersectionPoints.elementAt(0) +
                intersectionPoints.elementAt(1)) /
            2;

        final collisionVector = absoluteCenter - mid;
        double penetrationDepth = (size.x / 2) - collisionVector.length;
        print(collisionVector);
        collisionVector.normalize();
        print(collisionVector);
        position += collisionVector.scaled(penetrationDepth);
      }
    }
  }
}
