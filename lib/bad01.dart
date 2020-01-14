import 'dart:math';
import 'dart:ui';

import 'package:flame/components/component.dart';
import 'package:flame/flare_animation.dart';
import 'package:flame/position.dart';
import 'package:flame/time.dart';
import 'package:flutter/material.dart';
import 'package:ushoot/JoGame.dart';

///用 FlareComponent 來改的 Class。因為 FlareComponent 不能切換動畫(updateAnimation)
class Bad01 extends PositionComponent {
  FlareAnimation _flareAnimation;
  final JoGame game;
  final String fileName;
  String animName;
  bool isDead = false;
  bool toDestroy = false;
  double dir;

  double get bad01Size {
    return JoGame.unit * 2.4;
  }

  Rect get hitRect {
    Rect rr = toRect();
    return Rect.fromCenter(
            center: rr.center, width: rr.width / 4, height: rr.height / 6)
        .translate(0, rr.height / 15);
//    return Rect.fromLTRB(rr.left + width *2/5, rr.top + height * 4 / 9,
//        rr.right - width / 3, rr.bottom - width / 3);
  }

  Bad01(this.game, this.fileName, this.animName) {}

  void init(double width, double height) {
    this.width = width;
    this.height = height;

    FlareAnimation.load(fileName).then((loadedFlareAnimation) {
      _flareAnimation = loadedFlareAnimation;

      _flareAnimation.updateAnimation(animName);
      _flareAnimation.width = width;
      _flareAnimation.height = height;
    });
  }

  bool get isLeftDir {
    if (dir == null)
      return false;
    else
      return dir == 0 ? false : dir.abs() < pi / 2;
  }

  void toDead() {
    if (isDead) return;
    _flareAnimation.updateAnimation("Dead");
    isDead = true;
    countdown.start();
  }

  @override
  bool loaded() => _flareAnimation != null;

  @override
  void update(double dt) {
    if (_flareAnimation != null) {
      countdown.update(dt);

      if (countdown.isFinished()) {
        toDestroy = true;
      }

//      if (JoGame.walk) {
//        var target = toPosition().toOffset() + game.mapMoveStep;
//        var newOffset = Offset.lerp(toPosition().toOffset(), target, dt);
//        setByPosition(Position.fromOffset(newOffset));
//      }

      if (isLeftDir) {
        renderFlipX = true;
      } else {
        renderFlipX = false;
      }

      _flareAnimation.update(dt);
    }
  }

  @override
  void render(Canvas canvas) {
    prepareCanvas(canvas);
    if (!loaded()) return;

    _flareAnimation.render(canvas, x: 0, y: 0);
  }

  @override
  void resize(Size size) {
    init(bad01Size, bad01Size);
  }

  @override
  bool destroy() {
    return toDestroy;
  }

  final Timer countdown = Timer(.55);
}
