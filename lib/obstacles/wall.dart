import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class Wall extends PositionComponent {
  Wall({required size, required position})
      : super(size: size, position: position) {
    debugMode = true;
  }

  @override
  FutureOr<void> onLoad() {
    add(RectangleHitbox());
    return super.onLoad();
  }
}
