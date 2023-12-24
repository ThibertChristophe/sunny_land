import 'package:flutter/material.dart';
import 'package:flame/game.dart';
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
  List<String> levelNames = ['level1', 'level2', 'level3', 'level4'];
  int currentLevelIndex = 0;
  bool showControl = true;
  bool musicPlaying = true;
  int gemsCollected = 0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await FlameAudio.audioCache.load('coin.wav');
    await images.loadAll([
      'Joystick.png',
      'Knob.png',
      'middle2.png',
      'back.png',
    ]);
    fox = Player();
    _loadLevel();
    if (musicPlaying) {
      addMusic();
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    // ajuste la camera quand on passe la moitié de l'écran
    if (fox.position.x >= 400 && fox.position.x < 710) {
      //cam.viewfinder.position = Vector2(
      //  cam.viewfinder.position.x + fox.velocity.x * dt,
      //cam.viewfinder.position.y);
      cam.viewfinder.position =
          Vector2(fox.position.x - 400, cam.viewfinder.position.y);
    }
    if (showControl) {
      updateJoystick();
    }
  }

  //@override
  //void onDoubleTapDown(DoubleTapDownEvent event) {
  // fox.jump();
  //}

  /// Chargement du Level, init du Player, initialisation de la camera, ajout du joystickm du hud et bouton jump
  void _loadLevel() {
    fox = Player();
    Level world = Level(levelName: levelNames[currentLevelIndex], player: fox);
    cam = CameraComponent(world: world);
    cam.viewfinder.anchor = Anchor.topLeft;
    cam.viewfinder.position = Vector2(0, 20);
    //cam.viewfinder.visibleGameSize = Vector2(500, 570);
    cam.viewfinder.zoom = 2;
    //cam.viewport.size = Vector2(size.x, size.y);
    cam.viewport.anchor = Anchor.topLeft;
    cam.viewport.add(Hud());

    addJoystick();
    cam.viewport.add(JumpButton());
    addAll([cam, world]);
  }

  /// Delete le Level en cours et charge le suivant suivant l'index
  void loadNextLevel() {
    removeWhere((component) => component is Level);

    if (currentLevelIndex < levelNames.length - 1) {
      currentLevelIndex++;
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

    FlameAudio.bgm.play('background.mp3', volume: .3);
    musicPlaying = true;
  }

  // =============================== JOYSTICK =========================
  void addJoystick() {
    joystick = JoystickComponent(
      priority: 10,
      knob: SpriteComponent(
        sprite: Sprite(images.fromCache("Knob.png")),
        priority: 10,
        size: Vector2(75, 75),
      ),
      background: SpriteComponent(
        sprite: Sprite(images.fromCache("Joystick.png")),
        priority: 10,
        size: Vector2(150, 150),
      ),
      knobRadius: 75,
      margin: const EdgeInsets.only(left: 50, bottom: 40),
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
