import 'dart:ui';

import 'package:flame/components/animation_component.dart';

 abstract class Enemy extends AnimationComponent{
  Enemy.empty() : super.empty();

  Rect  hitRect;

  void toDead() {}
//  set hitRect(Rect rect);

}