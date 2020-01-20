import 'dart:ui';

import 'package:flame/components/animation_component.dart';
import 'package:ushoot/JoGame.dart';

abstract class Enemy extends AnimationComponent {
  final JoGame game;

  Enemy(this.game) : super.empty();

  Rect hitRect;

  void toDead() {}
//  set hitRect(Rect rect);

}
