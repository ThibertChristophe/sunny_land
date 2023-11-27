import 'package:flame/components.dart';

enum EnemyState { idle, jump, fall, death }

mixin class Enemies {
  bool dead = false;
  Vector2 velocity = Vector2(0, 0);
}
