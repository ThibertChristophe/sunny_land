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
import '../sunnyland.dart';

enum FoxDirection { left, right, none, down }

enum FoxState { running, jumping, falling, idle, hitted, sit }

class Player extends SpriteAnimationGroupComponent<FoxState>
    with CollisionCallbacks, KeyboardHandler, HasGameRef<SunnyLand> {
  Player({super.position})
      : super(size: Vector2.all(33), anchor: Anchor.center) {
    // debugMode = true;
  }
  double gravity = 7;
  Vector2 velocity = Vector2(0, 0);
  double moveSpeed = 100;
  FoxDirection horizontalDirection = FoxDirection.none;
  FoxDirection verticalDirection = FoxDirection.none;
  bool onGround = false;
  bool onPlatForm = false;
  final double jumpSpeed = 600;
  final double terminalVelocity = 150;

  final double _jumpLength = 250;

  bool isFalling = false;
  bool isHitted = false; // touché par un monstre
  bool collided = false; // quand on touche un mur
  FoxDirection collidedDirection = FoxDirection.none;

  @override
  void onLoad() async {
    animations = {
      FoxState.running: await game.loadSpriteAnimation(
        'run.png',
        SpriteAnimationData.sequenced(
          amount: 6,
          textureSize: Vector2.all(33),
          stepTime: 0.12,
        ),
      ),
      FoxState.hitted: await game.loadSpriteAnimation(
        'hitted.png',
        SpriteAnimationData.sequenced(
          amount: 2,
          textureSize: Vector2.all(33),
          stepTime: 0.12,
        ),
      ),
      FoxState.idle: await game.loadSpriteAnimation(
        'idle.png',
        SpriteAnimationData.sequenced(
          amount: 4,
          textureSize: Vector2.all(33),
          stepTime: 0.12,
        ),
      ),
      FoxState.sit: await game.loadSpriteAnimation(
        'down.png',
        SpriteAnimationData.sequenced(
          amount: 3,
          textureSize: Vector2.all(33),
          stepTime: 0.1,
          loop: false,
        ),
      ),
      FoxState.jumping: SpriteAnimation.spriteList(
        [await game.loadSprite('jumping.png')],
        stepTime: double.infinity,
      ),
      FoxState.falling: SpriteAnimation.spriteList(
        [await game.loadSprite('falling.png')],
        stepTime: double.infinity,
      ),
    };

    current = FoxState.idle;

    //add(CircleHitbox());
    add(PolygonHitbox([
      Vector2(24, 33),
      Vector2(24, 9),
      Vector2(4, 9),
      Vector2(4, 33),
    ], anchor: Anchor.bottomCenter));
  }

  @override
  void update(double dt) {
    super.update(dt);

    switch (horizontalDirection) {
      case FoxDirection.left:
        if (!collided || collidedDirection == FoxDirection.right) {
          if (position.x >= size.x) velocity.x = -1 * moveSpeed;
        }
        if (position.x <= 10) {
          velocity.x = 0;
        }
        break;
      case FoxDirection.right:
        if (!collided || collidedDirection == FoxDirection.left) {
          velocity.x = 1 * moveSpeed;
        }
        break;
      case FoxDirection.none:
        velocity.x = 0;
      default:
        velocity.x = 0;
    }

    // Gravité
    if (!onGround && !onPlatForm) {
      velocity.y += gravity;
      //position.y += velocity.y * dt;
      if (!isHitted) {
        // changement de > 7 en > 0
        if (velocity.y > 0) {
          current = FoxState.falling;
          isFalling = true;
        }
      }
    } else {
      isFalling = false;
      if (!isHitted) {
        if (verticalDirection == FoxDirection.down) {
          current = FoxState.sit;
        } else {
          current = (horizontalDirection == FoxDirection.none)
              ? FoxState.idle
              : FoxState.running;
        }
      }
      // Prevent from jumping to crazy fast as well as descending too fast and
      // crashing through the ground or a platform.
      velocity.y = velocity.y.clamp(-jumpSpeed, terminalVelocity);
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

    // On stop notre chute quand on est sur du Ground
    if (other is Ground) {
      if (intersectionPoints.length == 2) {
        Vector2 inter1 = intersectionPoints.elementAt(0);
        Vector2 inter2 = intersectionPoints.elementAt(1);

        // Sur notre ground
        if ((inter1.y.round() == other.y.round() &&
                    inter2.y.round() == other.y.round() ||
                (inter2.y.round() >= other.y.round() &&
                    inter1.y.round() == other.y.round()) ||
                (inter1.y.round() >= other.y.round() &&
                    inter2.y.round() == other.y.round())) &&
            current != FoxState.jumping) {
          if (intersectionPoints.length == 2) {
            final mid = (intersectionPoints.elementAt(0) +
                    intersectionPoints.elementAt(1)) /
                2;
            // Evite d'être en levitation sur le coté en dehors du ground
            final collisionVector = absoluteCenter - mid;
            double penetrationDepth = (size.x / 2) - collisionVector.length;
            collisionVector.normalize();

            position += collisionVector.scaled(penetrationDepth);
            velocity.y = 0;

            onGround = true;
          }
        }
        // on colle à droite du mur
        if (inter1.x == other.width + other.x &&
            inter2.x == other.width + other.x) {
          if (!collided) {
            collided = true;
            velocity.x = 0;
            // collidedDirection = horizontalDirection;
            collidedDirection = FoxDirection.left;
          }
        }
        // on colle à gauche du mur
        if (inter1.x == other.x && inter2.x == other.x) {
          if (!collided) {
            collided = true;
            velocity.x = 0;
            //collidedDirection = horizontalDirection;
            collidedDirection = FoxDirection.right;
          }
        }
        // on tappe sur le bas du sol
        if (inter1.y == other.height + other.y) {
          velocity.y = 0;
          onGround = false;
        }
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

          onPlatForm = true;
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
          // Vérifie que l'on est bien occupé de tomber et qu'on est au dessus du component
          if (isFalling &&
              (position.y < (other.position.y - (other.size.y / 2)))) {
            final mid = (intersectionPoints.elementAt(0) +
                    intersectionPoints.elementAt(1)) /
                2;

            final collisionVector = absoluteCenter - mid;
            double penetrationDepth = (size.x / 2) - collisionVector.length;

            collisionVector.normalize();

            position += collisionVector.scaled(penetrationDepth);
            current = FoxState.jumping;
            velocity.y -= _jumpLength;

            other.die();
          } else if (current != FoxState.hitted) {
            current = FoxState.hitted;
            isHitted = true;
            hittedEffect(intersectionPoints, other);
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

            current = FoxState.jumping;
            velocity.y -= _jumpLength;

            other.die();
          } else if (current != FoxState.hitted) {
            current = FoxState.hitted;
            isHitted = true;
            hittedEffect(intersectionPoints, other);
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

            current = FoxState.jumping;
            velocity.y -= _jumpLength;

            other.die();
          } else if (current != FoxState.hitted) {
            current = FoxState.hitted;
            isHitted = true;
            hittedEffect(intersectionPoints, other);
          }
        }
      }
    }
  }

  /// Joue l'effet d'être touché
  /// Nous fais faire un bond en arrière
  void hittedEffect(Set<Vector2> intersectionPoints, PositionComponent other) {
    // Si on est touché sur notre gauche
    if (intersectionPoints.first.x < other.position.x) {
      add(
        SequenceEffect(
          [
            MoveEffect.by(
              Vector2(-20, -15),
              EffectController(
                duration: 0.2,
                repeatCount: 1,
              ),
              onComplete: () => isHitted = false,
            ),
          ],
        ),
      );
    }
    // Si on est touché sur notre droite
    if (intersectionPoints.first.x > other.position.x) {
      add(SequenceEffect([
        MoveEffect.by(
          Vector2(20, -15),
          EffectController(
            duration: 0.2,
            repeatCount: 1,
          ),
          onComplete: () => isHitted = false,
        ),
      ]));
    }
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    super.onCollisionEnd(other);
    if (other is Platform) {
      onPlatForm = false;
    }
    if (other is Ground) {
      if (collided) {
        collidedDirection = FoxDirection.none;
        collided = false;
      }
      if (onGround) onGround = false;
    }
  }

  /// Fonction de saut vérifie qu'on est pas déjà occupé de sauter ou de tomber
  void jump() {
    if (current != FoxState.jumping && current != FoxState.falling) {
      velocity.y -= _jumpLength;
      current = FoxState.jumping;
      onGround = false;
      onPlatForm = false;
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
