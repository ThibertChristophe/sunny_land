import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/flame.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:sunny_land/hud.dart';
import 'package:sunny_land/actors/player.dart';
import 'package:sunny_land/jump_button.dart';
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
  late Player fox;
  List<String> levelNames = ['level1', 'level2'];
  int currentLevelIndex = 0;
  bool showControl = true;
  bool musicPlaying = false;
  int gemsCollected = 0;

  @override
  Future<void> onLoad() async {
    fox = Player();
    _loadLevel();

    await super.onLoad();
    if (musicPlaying) {
      addMusic();
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
      fox = Player();
      Level world =
          Level(levelName: levelNames[currentLevelIndex], player: fox);

      cam = CameraComponent.withFixedResolution(
          world: world, width: 1280, height: 800);
      cam.viewfinder.anchor = Anchor.topLeft;
      cam.viewfinder.position = Vector2(0, 20);
      //cam.viewfinder.visibleGameSize = Vector2(500, 570);
      cam.viewfinder.zoom = 1.5;
      cam.viewport.anchor = Anchor.topLeft;
      cam.viewport.add(Hud());

      if (showControl) {
        addJoystick();
      }
      cam.viewport.add(JumpButton());
      addAll([cam, world]);
    });
  }

  void loadNextLevel() {
    removeWhere((component) => component is Level);

    if (currentLevelIndex < levelNames.length - 1) {
      //     currentLevelIndex++;
      _loadLevel();
    } else {
      // no more levels
      currentLevelIndex = 0;
      _loadLevel();
    }
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
      priority: 10,
      knob: SpriteComponent(
        sprite: Sprite(
          await Flame.images.load('Knob.png'),
        ),
        priority: 10,
      ),
      background: SpriteComponent(
        sprite: Sprite(
          await Flame.images.load('Joystick.png'),
        ),
        priority: 10,
      ),
      knobRadius: 75,
      margin: const EdgeInsets.only(left: 100, bottom: 128),
    );

    cam.viewport.add(joystick);
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
