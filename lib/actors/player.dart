import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/services.dart';
import 'package:sunny_land/actors/eagle.dart';
import 'package:sunny_land/actors/frog.dart';
import 'package:sunny_land/actors/opposum.dart';
import 'package:sunny_land/objects/cherry.dart';
import 'package:sunny_land/objects/gem.dart';
import 'package:sunny_land/obstacles/ground.dart';
import 'package:sunny_land/obstacles/platform.dart';
import 'package:sunny_land/obstacles/wall.dart';
import '../sunnyland.dart';

enum FoxDirection { left, right, none, down }

enum PlayerState { running, jumping, falling, idle, hitted, sit }

class Player extends SpriteAnimationGroupComponent<PlayerState>
    with CollisionCallbacks, KeyboardHandler, HasGameRef<SunnyLand> {
  Player({required super.position})
      : super(size: Vector2.all(33), anchor: Anchor.center) {
    debugMode = true;
  }
  double gravity = 7;
  Vector2 velocity = Vector2(0, 0);
  double moveSpeed = 160;
  FoxDirection horizontalDirection = FoxDirection.none;
  FoxDirection verticalDirection = FoxDirection.none;
  bool onGround = false;
  final double jumpSpeed = 600;
  final double terminalVelocity = 150;

  final double _jumpLength = 250;

  bool isFalling = false;

  bool collided = false;
  FoxDirection collidedDirection = FoxDirection.none;

  @override
  void onLoad() async {
    animations = {
      PlayerState.running: await game.loadSpriteAnimation(
        'run.png',
        SpriteAnimationData.sequenced(
          amount: 6,
          textureSize: Vector2.all(33),
          stepTime: 0.15,
        ),
      ),
      PlayerState.hitted: await game.loadSpriteAnimation(
        'hitted.png',
        SpriteAnimationData.sequenced(
          amount: 2,
          textureSize: Vector2.all(33),
          stepTime: 0.15,
        ),
      ),
      PlayerState.idle: await game.loadSpriteAnimation(
        'idle.png',
        SpriteAnimationData.sequenced(
          amount: 4,
          textureSize: Vector2.all(33),
          stepTime: 0.15,
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

    add(CircleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (position.x <= 32) {
      velocity.x = 0;
    }
    // print("Collided : $collided");
    // print("Coté collided : $collidedDirection");
    // print("Direction joystick : $horizontalDirection");
    switch (horizontalDirection) {
      case FoxDirection.left:
        if (!collided || collidedDirection == FoxDirection.right) {
          if (position.x >= size.x / 2) velocity.x = -1 * moveSpeed;
        }

        break;
      case FoxDirection.right:
        if (!collided || collidedDirection == FoxDirection.left) {
          velocity.x = 1 * moveSpeed;
        }
        break;
      case FoxDirection.none:
      default:
        velocity.x = 0;
    }

    // Gravité
    if (!onGround) {
      velocity.y += gravity;
      //position.y += velocity.y * dt;
      if (velocity.y > 7) {
        current = PlayerState.falling;
        isFalling = true;
      }
    } else {
      isFalling = false;
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
    // print(position);
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
        onGround = true;
      }
    }
    if (other is Wall) {
      if (!collided) {
        velocity.x = 0;
        collided = true;
        collidedDirection = horizontalDirection;
      }
    }
    if (other is Platform) {
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
    if (other is Gem) {
      if (intersectionPoints.length == 2) {
        other.hitted();
      }
    }
    if (other is Frog) {
      if (!other.dead) {
        if (intersectionPoints.length == 2) {
          if (isFalling &&
              (position.y < (other.position.y - (other.size.y / 2)))) {
            final mid = (intersectionPoints.elementAt(0) +
                    intersectionPoints.elementAt(1)) /
                2;

            final collisionVector = absoluteCenter - mid;
            double penetrationDepth = (size.x / 2) - collisionVector.length;

            collisionVector.normalize();

            position += collisionVector.scaled(penetrationDepth);
            current = PlayerState.jumping;
            velocity.y -= _jumpLength;

            other.die();
          } else if (current != PlayerState.hitted) {
            current = PlayerState.hitted;
            if (intersectionPoints.first.x < other.position.x) {
              add(SequenceEffect([
                MoveEffect.by(
                  Vector2(-1, -1),
                  EffectController(
                    duration: 0.1,
                    repeatCount: 1,
                  ),
                ),
              ]));
            }
            if (intersectionPoints.first.x > other.position.x) {
              add(SequenceEffect([
                MoveEffect.by(
                  Vector2(1, -1),
                  EffectController(
                    duration: 0.1,
                    repeatCount: 1,
                  ),
                ),
              ]));
            }
          }
        }
      }
    }
    if (other is Oposum) {
      if (!other.dead) {
        if (intersectionPoints.length == 2) {
          if (isFalling &&
              (position.y < (other.position.y - (other.size.y / 2)))) {
            final mid = (intersectionPoints.elementAt(0) +
                    intersectionPoints.elementAt(1)) /
                2;

            final collisionVector = absoluteCenter - mid;
            double penetrationDepth = (size.x / 2) - collisionVector.length;

            collisionVector.normalize();

            position += collisionVector.scaled(penetrationDepth);

            current = PlayerState.jumping;
            velocity.y -= _jumpLength;

            other.die();
          } else if (current != PlayerState.hitted) {
            current = PlayerState.hitted;
            if (intersectionPoints.first.x < other.position.x) {
              add(SequenceEffect([
                MoveEffect.by(
                  Vector2(-1, -1),
                  EffectController(
                    duration: 0.1,
                    repeatCount: 1,
                  ),
                ),
              ]));
            }
            if (intersectionPoints.first.x > other.position.x) {
              add(SequenceEffect([
                MoveEffect.by(
                  Vector2(1, -1),
                  EffectController(
                    duration: 0.1,
                    repeatCount: 1,
                  ),
                ),
              ]));
            }
          }
        }
      }
    }
    if (other is Eagle) {
      if (!other.dead) {
        if (intersectionPoints.length == 2) {
          if (isFalling &&
              (position.y < (other.position.y - (other.size.y / 2)))) {
            final mid = (intersectionPoints.elementAt(0) +
                    intersectionPoints.elementAt(1)) /
                2;

            final collisionVector = absoluteCenter - mid;
            double penetrationDepth = (size.x / 2) - collisionVector.length;

            collisionVector.normalize();

            position += collisionVector.scaled(penetrationDepth);

            current = PlayerState.jumping;
            velocity.y -= _jumpLength;

            other.die();
          } else if (current != PlayerState.hitted) {
            current = PlayerState.hitted;
            if (intersectionPoints.first.x < other.position.x) {
              add(SequenceEffect([
                MoveEffect.by(
                  Vector2(-1, -1),
                  EffectController(
                    duration: 0.1,
                    repeatCount: 1,
                  ),
                ),
              ]));
            }
            if (intersectionPoints.first.x > other.position.x) {
              add(SequenceEffect([
                MoveEffect.by(
                  Vector2(1, -1),
                  EffectController(
                    duration: 0.1,
                    repeatCount: 1,
                  ),
                ),
              ]));
            }
          }
        }
      }
    }
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    super.onCollisionEnd(other);
    if (other is Platform) {
      onGround = false;
    }
    if (other is Ground) {
      onGround = false;
    }
    if (other is Wall) {
      collidedDirection = FoxDirection.none;
      collided = false;
    }
  }

  void jump() {
    if (current != PlayerState.jumping && current != PlayerState.falling) {
      velocity.y -= _jumpLength;
      current = PlayerState.jumping;
      onGround = false;
    }
  }

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    horizontalDirection = FoxDirection.none;
    if (keysPressed.contains(LogicalKeyboardKey.keyA) ||
        keysPressed.contains(LogicalKeyboardKey.arrowLeft)) {
      horizontalDirection = FoxDirection.left;
    } else if (keysPressed.contains(LogicalKeyboardKey.keyD) ||
        keysPressed.contains(LogicalKeyboardKey.arrowRight)) {
      horizontalDirection = FoxDirection.right;
    }
    if (keysPressed.contains(LogicalKeyboardKey.space)) {
      jump();
    }

    return true;
  }
}
