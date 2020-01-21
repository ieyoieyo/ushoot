import 'dart:ui';

import 'package:flame/animation.dart';
import 'package:flame/components/animation_component.dart';
import 'package:flame/sprite.dart';
import 'package:ushoot/JoGame.dart';
import 'package:ushoot/util.dart';

abstract class Enemy extends AnimationComponent {
  final JoGame game;
  Animation explodeAnim;
  Rect hitRect;

  Enemy(this.game) : super.empty() {
    explodeAnim = Util.atlasSprite("8.png", 90, 8, 64.0, 48.0, .0125, false);
  }

  void toDead() {}
//  set hitRect(Rect rect);

}
