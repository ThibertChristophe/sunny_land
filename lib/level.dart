import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/parallax.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/widgets.dart';
import 'package:sunny_land/sunnyland.dart';
import 'package:sunny_land/objects/end.dart';
import 'package:sunny_land/objects/gem.dart';
import 'package:sunny_land/obstacles/ground.dart';
import 'package:sunny_land/obstacles/platform.dart';

import 'package:sunny_land/actors/player.dart';
import 'package:sunny_land/actors/eagle.dart';
import 'package:sunny_land/actors/frog.dart';
import 'package:sunny_land/actors/opposum.dart';

class Level extends World with HasGameRef<SunnyLand> {
  final String levelName;
  final Player player;
  Level({required this.levelName, required this.player});
  late TiledComponent level;

  @override
  FutureOr<void> onLoad() async {
    // Loading de la map en fonction du numero de niveau
    level = await TiledComponent.load('$levelName.tmx', Vector2.all(16));
    add(level);
    // Fond en parallax
    ParallaxComponent sky = await ParallaxComponent.load(
      [
        ParallaxImageData('back.png'),
      ],
      size: Vector2(game.size.x, game.size.y / 2),
      alignment: Alignment.topLeft,
      repeat: ImageRepeat.repeat,
      baseVelocity: Vector2(5, 0),
      velocityMultiplierDelta: Vector2(2, 1),
      priority: -1,
    );
    add(sky);

    _addCollision();
    _spawnObject();

    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Cas où le joueur tombe dans le vide
    // On le fait respawn au debut du niveau
    if (player.position.y >= game.size.y) {
      remove(player);
      // On reprend sa position d'origine sur la map
      final players = level.tileMap.getLayer<ObjectGroup>('player');
      if (players != null) {
        for (final obj in players.objects) {
          player.position = Vector2(obj.x, obj.y);
          player.scale.x = 1;
          add(player);
          // On replace la camera au debut du niveau
          game.cam.viewfinder.position = Vector2(0, 20);
        }
      }
    }
  }

  /// Creation des collision de la map
  void _addCollision() {
    final grounds = level.tileMap.getLayer<ObjectGroup>('grounds');
    final platforms = level.tileMap.getLayer<ObjectGroup>('platforms');

    if (grounds != null) {
      for (final obj in grounds.objects) {
        add(Ground(
            size: Vector2(obj.width, obj.height),
            position: Vector2(obj.x, obj.y)));
      }
    }
    if (platforms != null) {
      for (final obj in platforms.objects) {
        add(Platform(
            size: Vector2(obj.width, obj.height),
            position: Vector2(obj.x, obj.y)));
      }
    }
  }

  /// Creation des objets de la map (gem, ennemi, joueur, etc)
  void _spawnObject() {
    final gems = level.tileMap.getLayer<ObjectGroup>('gems');
    final players = level.tileMap.getLayer<ObjectGroup>('player');
    final enemies = level.tileMap.getLayer<ObjectGroup>('enemies');
    final endButton = level.tileMap.getLayer<ObjectGroup>('endButton');

    if (endButton != null) {
      for (final obj in endButton.objects) {
        add(EndButton(
            size: Vector2(obj.width, obj.height),
            position: Vector2(obj.x, obj.y)));
      }
    }
    if (gems != null) {
      for (final obj in gems.objects) {
        add(Gem(position: Vector2(obj.x, obj.y)));
      }
    }
    if (players != null) {
      for (final obj in players.objects) {
        player.position = Vector2(obj.x, obj.y);
        player.scale.x = 1;
        add(player);
      }
    }
    if (enemies != null) {
      for (final obj in enemies.objects) {
        switch (obj.class_) {
          case 'frogs':
            add(Frog(position: Vector2(obj.x, obj.y)));
            break;
          case 'oposum':
            add(Oposum(position: Vector2(obj.x, obj.y)));
            break;
          case 'eagle':
            add(Eagle(position: Vector2(obj.x, obj.y)));
            break;
          default:
        }
      }
    }
  }
}
