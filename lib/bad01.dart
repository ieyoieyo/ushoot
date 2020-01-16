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
  final String animName;
  bool isDead = false;
  bool toDestroy = false;
  double dir;
  Paint debugPaint = Paint()..color = Colors.lightGreenAccent.withAlpha(200);

  double get bad01Size => JoGame.unit * 2.4;

//  Rect get hitRect {
//    return Rect.fromCenter(
//      center: Offset(
//        width / 2,
//        height / 2 + height / 20,
//      ),
//      width: width *2/7,
//      height: height / 5,
//    );
//  }
  Rect hitRect;

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

    hitRect = Rect.fromCenter(
      center: Offset(
        width / 2,
        height / 2 + height / 20,
      ),
      width: width *2/7,
      height: height / 5,
    );

    newPos = nextPosition();
  }

  bool get isLeftDir {
    if (dir == null)
      return false;
    else
      return dir == 0 ? false : dir.abs() > pi / 2;
  }

  void toDead() {
    if (isDead) return;
    _flareAnimation.updateAnimation("Dead");
    isDead = true;
    deadAnimCountdown.start();
  }

  @override
  bool loaded() => _flareAnimation != null;

  Position newPos;

  double get speed => JoGame.unit * .4;

  Position nextPosition() {
    ///要算壞人到主角的offset和角度，竟是用 (主角 - 壞人)？！不太懂！
    var diffOffset = (game.judo.toPosition() - toPosition()).toOffset();
    dir = diffOffset.direction;
    var dis = Random().nextDouble() * 2 * JoGame.unit + JoGame.unit / 3;
//    print("my var >> ${diffOffset}");
    if (diffOffset.dx.abs() > JoGame.unit * 7 ||
        diffOffset.dy.abs() > JoGame.unit * 3) {
//      print(" x,y方向都太遠");
      newPos = Position.fromOffset(toPosition().toOffset() +
          Offset.fromDirection(diffOffset.direction, dis));
    } else {
//      print("近");
      int upDown = Random().nextBool() ? 1 : -1;
      dir = Random().nextDouble() * pi * upDown;
      newPos = Position.fromOffset(
          toPosition().toOffset() + Offset.fromDirection(dir, dis));
    }
    return newPos;
  }

  @override
  int priority() {
    return y.toInt();
  }

  @override
  void update(double dt) {
    if (!loaded()) return;

    deadAnimCountdown.update(dt);

    if (deadAnimCountdown.isFinished()) {
      toDestroy = true;
    }

    renderFlipX = isLeftDir;

    var step = speed * dt;
    if (toPosition().distance(newPos) < step) {
      setByPosition(newPos);
      newPos = nextPosition();
    } else {
      var diff = newPos - toPosition();
      var move = Offset.fromDirection(diff.toOffset().direction, step);
      setByPosition(toPosition() + Position.fromOffset(move));
    }

    _flareAnimation.update(dt);
  }

  @override
  void render(Canvas canvas) {
    prepareCanvas(canvas);
    if (!loaded()) return;

    _flareAnimation.render(canvas, x: 0, y: 0);

//    if (game.isDebug) canvas.drawRect(hitRect, debugPaint);
  }

  @override
  void resize(Size size) {
    init(bad01Size, bad01Size);
  }

  @override
  bool destroy() {
    return toDestroy;
  }

  final Timer deadAnimCountdown = Timer(.55);
}
