import 'dart:ui';

import 'package:flame/components/component.dart';
import 'package:ushoot/JoGame.dart';

class JoMap extends SpriteComponent {
  JoGame game;

  JoMap(this.game) : super.square(1300.0, "map.png") {
    x = -220.0;
    y = -285.0;
  }

  @override
  int priority() {
    //其他component用 y 當priority,這邊讓此Map為最底層(數字最小/最先render)
    return -9999;
  }

  @override
  void resize(Size size) {}
}
