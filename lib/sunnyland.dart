import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/widgets.dart';
import 'package:sunny_land/obstacles/ground.dart';
import 'package:sunny_land/obstacles/wall.dart';

import 'actors/player.dart';

class SunnyLand extends FlameGame with HasCollisionDetection {
  SunnyLand();
  late JoystickComponent joystick; // Joystick
  late Player fox;

  late TiledComponent myMap;
  @override
  final world = World();
  late final CameraComponent cameraComponent;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    addJoystick();
    myMap = await TiledComponent.load("map1_1.tmx", Vector2.all(16));
    add(myMap);

    final ground = myMap.tileMap.getLayer<ObjectGroup>('collision');
    final wall = myMap.tileMap.getLayer<ObjectGroup>('mur');
    for (final obj in ground!.objects) {
      add(Ground(
          size: Vector2(obj.width, obj.height),
          position: Vector2(obj.x, obj.y)));
    }
    for (final obj in wall!.objects) {
      add(Wall(
          size: Vector2(obj.width, obj.height),
          position: Vector2(obj.x, obj.y)));
    }
    cameraComponent =
        CameraComponent.withFixedResolution(width: 1600, height: 720);

    addAll([cameraComponent, world]);

    fox = Player(position: Vector2(100, 0));
    add(fox);
  }

  @override
  void update(double dt) {
    super.update(dt);
    updateJoystick();
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
      case JoystickDirection.downLeft:
      case JoystickDirection.upLeft:
      case JoystickDirection.left:
        fox.horizontalDirection = FoxDirection.left;
        break;
      case JoystickDirection.downRight:
      case JoystickDirection.upRight:
      case JoystickDirection.right:
        fox.horizontalDirection = FoxDirection.right;
        break;
      default:
        fox.horizontalDirection = FoxDirection.none;
        break;
    }
  }
}
