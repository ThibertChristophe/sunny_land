import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/flame.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:sunny_land/hud.dart';
import 'package:sunny_land/actors/player.dart';
import 'package:sunny_land/level.dart';

class SunnyLand extends FlameGame
    with
        DoubleTapCallbacks,
        HasKeyboardHandlerComponents,
        HasCollisionDetection {
  SunnyLand();
  late Hud hud;
  late JoystickComponent joystick; // Joystick
  late CameraComponent cam;
  Player fox = Player();
  List<String> levelNames = ['level1', 'level2'];
  int currentLevelIndex = 0;
  bool showControl = true;
  bool musicPlaying = false;
  int gemsCollected = 0;

  @override
  Future<void> onLoad() async {
    _loadLevel();

    await super.onLoad();
    if (musicPlaying) {
      addMusic();
    }
    if (showControl) {
      addJoystick();
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    // ajuste la camera quand on passe la moitié de l'écran
    if (fox.position.x >= 500 && fox.position.x < 860) {
      cam.viewfinder.position = Vector2(
          cam.viewfinder.position.x + fox.velocity.x * dt,
          cam.viewfinder.position.y);
    }
    if (showControl) {
//      updateJoystick();
    }
  }

  @override
  void onDoubleTapDown(DoubleTapDownEvent event) {
    fox.jump();
  }

  void _loadLevel() {
    Future.delayed(const Duration(seconds: 1), () {
      Level world =
          Level(levelName: levelNames[currentLevelIndex], player: fox);

      cam = CameraComponent.withFixedResolution(
          world: world, width: 1280, height: 800);
      cam.viewfinder.anchor = Anchor.topLeft;
      cam.viewfinder.position = Vector2(0, 20);
      //cam.viewfinder.visibleGameSize = Vector2(500, 570);
      cam.viewfinder.zoom = 1.4;
      cam.viewport.anchor = Anchor.topLeft;
      cam.viewport.add(Hud());

      addAll([cam, world]);
    });
  }

// =============================== MUSIC =========================
  void addMusic() {
    FlameAudio.bgm.initialize();

    FlameAudio.bgm.play('background.mp3', volume: .5);
    musicPlaying = true;
  }

  // =============================== JOYSTICK =========================
  void addJoystick() async {
    joystick = JoystickComponent(
      priority: 1000,
      knob: SpriteComponent(
        sprite: Sprite(
          await Flame.images.load('Knob.png'),
        ),
      ),
      background: SpriteComponent(
        sprite: Sprite(
          await Flame.images.load('Joystick.png'),
        ),
      ),
      knobRadius: 75,
      margin: const EdgeInsets.only(left: 64, bottom: 64),
    );

    add(joystick);
  }

  void updateJoystick() {
    if (fox.current == FoxState.hitted) {
      fox.verticalDirection = FoxDirection.none;
      fox.horizontalDirection = FoxDirection.none;
    } else {
      switch (joystick.direction) {
        case JoystickDirection.down:
          fox.verticalDirection = FoxDirection.down;
          fox.horizontalDirection = FoxDirection.none;
          break;
        case JoystickDirection.downLeft:
        case JoystickDirection.upLeft:
        case JoystickDirection.left:
          fox.horizontalDirection = FoxDirection.left;
          fox.verticalDirection = FoxDirection.none;
          break;
        case JoystickDirection.downRight:
        case JoystickDirection.upRight:
        case JoystickDirection.right:
          fox.horizontalDirection = FoxDirection.right;
          fox.verticalDirection = FoxDirection.none;
          break;
        default:
          fox.verticalDirection = FoxDirection.none;
          fox.horizontalDirection = FoxDirection.none;
          break;
      }
    }
  }
}
