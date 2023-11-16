import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:sunny_land/obstacles/ground.dart';
import 'package:sunny_land/obstacles/wall.dart';
import '../sunnyland.dart';

enum FoxDirection { left, right, none }

enum PlayerState { running, jumping, falling, idle, hitted }

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

  final double _jumpLength = 50;

  bool get isFalling => _lastPosition.y < position.y;

  Vector2 _lastPosition = Vector2.zero();

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
      PlayerState.hitted: await game.loadSpriteAnimation(
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
      PlayerState.jumping: SpriteAnimation.spriteList(
        [await game.loadSprite('jumping.png')],
        stepTime: double.infinity,
      ),
      PlayerState.falling: SpriteAnimation.spriteList(
        [await game.loadSprite('falling.png')],
        stepTime: double.infinity,
      ),
    };

    current = PlayerState.idle;
    _lastPosition.setFrom(position);
    add(CircleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Gravité
    if (!onGround) {
      velocity.y += gravity;
      position.y += velocity.y * dt;
    }

    switch (horizontalDirection) {
      case FoxDirection.left:
        velocity.x = -1 * moveSpeed;
        if (onGround) current = PlayerState.running;
        break;
      case FoxDirection.right:
        velocity.x = 1 * moveSpeed;
        if (onGround) current = PlayerState.running;
        break;
      case FoxDirection.none:
        velocity.x = 0;
        if (onGround) current = PlayerState.idle;
        break;
      default:
        velocity.x = 0 * moveSpeed;
        if (onGround) current = PlayerState.idle;
        break;
    }

    if (horizontalDirection == FoxDirection.left && scale.x > 0) {
      flipHorizontally();
    } else if (horizontalDirection == FoxDirection.right && scale.x < 0) {
      flipHorizontally();
    }
    position += velocity * dt;
    _lastPosition = position;
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
      }
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

        collisionVector.normalize(); // rend le vector2(x,y) positif ou négatif

        position += collisionVector.scaled(penetrationDepth);
      }
    }
  }

  void jump() {
    current = PlayerState.jumping;
    onGround = false;
    velocity.y -= _jumpLength;
  }
}
