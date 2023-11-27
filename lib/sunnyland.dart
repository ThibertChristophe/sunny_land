import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/widgets.dart';
import 'package:sunny_land/actors/eagle.dart';
import 'package:sunny_land/actors/frog.dart';
import 'package:sunny_land/actors/opposum.dart';
import 'package:sunny_land/objects/cherry.dart';
import 'package:sunny_land/objects/gem.dart';
import 'package:sunny_land/obstacles/ground.dart';
import 'package:sunny_land/obstacles/platform.dart';
import 'package:flutter/material.dart';
import 'package:sunny_land/obstacles/wall.dart';
import 'actors/player.dart';

class SunnyLand extends FlameGame
    with
        DoubleTapCallbacks,
        HasKeyboardHandlerComponents,
        HasCollisionDetection {
  SunnyLand();

  late JoystickComponent joystick; // Joystick
  late Player fox;
  late Frog frog;
  late Cherry cherry;

  late TiledComponent myMap;
  @override
  final world = World();
  late final CameraComponent cameraComponent;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    addJoystick();
    myMap = await TiledComponent.load("training.tmx", Vector2.all(16));
    add(myMap);

    final ground = myMap.tileMap.getLayer<ObjectGroup>('ground');
    final platform = myMap.tileMap.getLayer<ObjectGroup>('platform');
    final walls = myMap.tileMap.getLayer<ObjectGroup>('wall');
    final cherries = myMap.tileMap.getLayer<ObjectGroup>('cherry');
    final gems = myMap.tileMap.getLayer<ObjectGroup>('gems');
    final player = myMap.tileMap.getLayer<ObjectGroup>('player');
    final frogs = myMap.tileMap.getLayer<ObjectGroup>('frogs');
    final enemies = myMap.tileMap.getLayer<ObjectGroup>('Enemy');
    for (final obj in ground!.objects) {
      add(Ground(
          size: Vector2(obj.width, obj.height),
          position: Vector2(obj.x, obj.y)));
    }
    for (final obj in platform!.objects) {
      add(Platform(
          size: Vector2(obj.width, obj.height),
          position: Vector2(obj.x, obj.y)));
    }
    for (final obj in walls!.objects) {
      add(Wall(
          size: Vector2(obj.width, obj.height),
          position: Vector2(obj.x, obj.y)));
    }
    for (final obj in cherries!.objects) {
      add(Cherry(position: Vector2(obj.x, obj.y)));
    }
    for (final obj in gems!.objects) {
      add(Gem(position: Vector2(obj.x, obj.y)));
    }
    for (final obj in player!.objects) {
      add(fox = Player(position: Vector2(obj.x, obj.y)));
    }
    for (final obj in enemies!.objects) {
      switch (obj.class_) {
        case 'Frogs':
          add(Frog(position: Vector2(obj.x, obj.y)));
          break;
        case 'Oposum':
          add(Oposum(position: Vector2(obj.x, obj.y)));
          break;
        case 'Eagle':
          add(Eagle(position: Vector2(obj.x, obj.y)));
          break;
      }
    }

    cameraComponent =
        CameraComponent.withFixedResolution(width: 1600, height: 720);
    //cameraComponent.viewfinder.anchor = Anchor.bottomLeft;

    addAll([cameraComponent, world]);
  }

  @override
  void update(double dt) {
    super.update(dt);
    // updateJoystick();
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
    add(joystick);
  }

  void updateJoystick() {
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

  @override
  void onDoubleTapDown(DoubleTapDownEvent event) {
    fox.jump();
  }
}
