import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/flame.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:sunny_land/actors/eagle.dart';
import 'package:sunny_land/actors/frog.dart';
import 'package:sunny_land/actors/opposum.dart';
import 'package:sunny_land/hud.dart';
import 'package:sunny_land/objects/door.dart';
import 'package:sunny_land/objects/gem.dart';
import 'package:sunny_land/obstacles/ground.dart';
import 'package:sunny_land/obstacles/platform.dart';
import 'package:sunny_land/actors/player.dart';

class SunnyLand extends FlameGame
    with
        DoubleTapCallbacks,
        HasKeyboardHandlerComponents,
        HasCollisionDetection {
  SunnyLand();
  bool musicPlaying = false;
  late Hud hud;
  late Player fox;
  int gemsCollected = 0;
  late TiledComponent myMap;
  late JoystickComponent joystick; // Joystick

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    addMusic();
    addJoystick();

    myMap = await TiledComponent.load("level1.tmx", Vector2.all(16));
    world.add(myMap);

    buildMap();

    // 1280x800
    camera.viewfinder.anchor = Anchor.topLeft;
    camera.viewfinder.visibleGameSize = Vector2(500, 570);
    camera.viewfinder.position = Vector2(0, 0);
    camera.viewport.anchor = Anchor.topLeft;

    camera.viewport.add(Hud());
  }

  @override
  void update(double dt) {
    super.update(dt);
    //updateJoystick();
    // ajuste la camera quand on passe la moitié de l'écran
    if (fox.position.x >= 500 && fox.position.x < 925) {
      camera.viewfinder.position = Vector2(
          camera.viewfinder.position.x + fox.velocity.x * dt,
          camera.viewfinder.position.y);
    }
  }

  @override
  void onDoubleTapDown(DoubleTapDownEvent event) {
    fox.jump();
  }

  // =============================== MUSIC =========================
  void addMusic() {
    FlameAudio.bgm.initialize();

    // if (!musicPlaying) {
    //   FlameAudio.bgm.play('background.mp3', volume: .5);
    //   musicPlaying = true;
    // }
  }

  // =============================== MAP =========================
  void buildMap() {
    final grounds = myMap.tileMap.getLayer<ObjectGroup>('grounds');
    final platforms = myMap.tileMap.getLayer<ObjectGroup>('platforms');

    //final cherries = myMap.tileMap.getLayer<ObjectGroup>('cherry');
    final gems = myMap.tileMap.getLayer<ObjectGroup>('gems');
    final player = myMap.tileMap.getLayer<ObjectGroup>('player');
    final interacts = myMap.tileMap.getLayer<ObjectGroup>('interact');
    final enemies = myMap.tileMap.getLayer<ObjectGroup>('enemies');

    if (grounds != null) {
      for (final obj in grounds.objects) {
        world.add(Ground(
            size: Vector2(obj.width, obj.height),
            position: Vector2(obj.x, obj.y)));
      }
    }
    if (platforms != null) {
      for (final obj in platforms.objects) {
        world.add(Platform(
            size: Vector2(obj.width, obj.height),
            position: Vector2(obj.x, obj.y)));
      }
    }
    if (interacts != null) {
      for (final obj in interacts.objects) {
        add(Door(position: Vector2(obj.x, obj.y)));
      }
    }
    // for (final obj in cherries!.objects) {
    //   add(Cherry(position: Vector2(obj.x, obj.y)));
    // }
    if (gems != null) {
      for (final obj in gems.objects) {
        world.add(Gem(position: Vector2(obj.x, obj.y)));
      }
    }
    if (player != null) {
      for (final obj in player.objects) {
        world.add(fox = Player(position: Vector2(obj.x, obj.y)));
      }
    }
    if (enemies != null) {
      for (final obj in enemies.objects) {
        switch (obj.class_) {
          case 'frogs':
            world.add(Frog(position: Vector2(obj.x, obj.y)));
            break;
          case 'oposum':
            world.add(Oposum(position: Vector2(obj.x, obj.y)));
            break;
          case 'eagle':
            world.add(Eagle(position: Vector2(obj.x, obj.y)));
            break;
        }
      }
    }
  }

  // =============================== JOYSTICK =========================
  void addJoystick() async {
    joystick = JoystickComponent(
      priority: 10,
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

    camera.viewport.add(joystick);
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
