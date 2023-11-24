import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:sunny_land/actors/frog.dart';
import 'package:sunny_land/objects/cherry.dart';
import 'package:sunny_land/obstacles/ground.dart';
import 'package:sunny_land/obstacles/platform.dart';
import '../sunnyland.dart';

enum FoxDirection { left, right, none, down }

enum PlayerState { running, jumping, falling, idle, hitted, sit }

class Player extends SpriteAnimationGroupComponent<PlayerState>
    with CollisionCallbacks, HasGameRef<SunnyLand> {
  Player({required super.position})
      : super(size: Vector2.all(33), anchor: Anchor.center) {
    debugMode = true;
  }
  double gravity = 5;
  Vector2 velocity = Vector2(0, 0);
  double moveSpeed = 180;
  FoxDirection horizontalDirection = FoxDirection.none;
  FoxDirection verticalDirection = FoxDirection.none;
  bool onGround = false;
  final double jumpSpeed = 600;
  final double terminalVelocity = 150;

  final double _jumpLength = 140;

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
      PlayerState.sit: await game.loadSpriteAnimation(
        'down.png',
        SpriteAnimationData.sequenced(
          amount: 3,
          textureSize: Vector2.all(33),
          stepTime: 0.1,
          loop: false,
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

    if (verticalDirection == FoxDirection.none) {
      switch (horizontalDirection) {
        case FoxDirection.left:
          velocity.x = -1 * moveSpeed;
          break;
        case FoxDirection.right:
          velocity.x = 1 * moveSpeed;
          break;
        case FoxDirection.none:
        default:
          velocity.x = 0;
      }
    }

    if (onGround) {
      if (verticalDirection == FoxDirection.down) {
        current = PlayerState.sit;
      } else {
        current = (horizontalDirection == FoxDirection.none)
            ? PlayerState.idle
            : PlayerState.running;
      }
    }
    // Prevent from jumping to crazy fast as well as descending too fast and
    // crashing through the ground or a platform.
    velocity.y = velocity.y.clamp(-jumpSpeed, terminalVelocity);

    if (horizontalDirection == FoxDirection.left && scale.x > 0) {
      flipHorizontally();
    } else if (horizontalDirection == FoxDirection.right && scale.x < 0) {
      flipHorizontally();
    }
    // print(velocity.y);
    if (verticalDirection == FoxDirection.none) {
      position += velocity * dt;
    }
    _lastPosition = position;
    onGround =
        false; // force le fait qu'on est par défaut en chute libre pour detecter quand on quitte le sol pour tomber
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
    } else if (other is Platform) {
      if (other.active) {
        // Si la plate forme est active (le joueur est au dessus) alors on active les collisions
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
    if (other is Cherry) {
      if (intersectionPoints.length == 2) {
        other.hitted();
      }
    }
    if (other is Frog) {
      if (intersectionPoints.length == 2) {
        double temp = other.position.y - other.size.y;
        if (intersectionPoints.last.y < temp) {
          print('HAUT');
        }

        if (intersectionPoints.first.x < other.position.x) {
          add(SequenceEffect([
            MoveEffect.by(
              Vector2(-1, -2),
              EffectController(
                duration: 0.2,
                repeatCount: 2,
              ),
            ),
          ]));
        }
        if (intersectionPoints.first.x > other.position.x) {
          add(SequenceEffect([
            MoveEffect.by(
              Vector2(1, -2),
              EffectController(
                duration: 0.2,
                repeatCount: 2,
              ),
            ),
          ]));
        }
        current = PlayerState.hitted;
      }
    }
  }

  void jump() {
    current = PlayerState.jumping;
    onGround = false;

    velocity.y -= _jumpLength;
  }
}
