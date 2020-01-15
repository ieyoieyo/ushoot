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
  Paint debugPaint = Paint()..color = Colors.lightGreenAccent.withAlpha(200);

  double get bad01Size {
    return JoGame.unit * 2.4;
  }

  Rect get hitRect {
    return Rect.fromCenter(
      center: Offset(
        width / 2,
        height / 2 + height / 15,
      ),
      width: width / 4,
      height: height / 6,
    );
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
      return dir == 0 ? false : dir.abs() > pi / 2;
  }

  void toDead() {
    if (isDead) return;
    _flareAnimation.updateAnimation("Dead");
    isDead = true;
    countdown.start();
  }

  @override
  bool loaded() => _flareAnimation != null;

  bool nextPosFlag = false;
  Position newPos;

  Position nextPosition() {
    var diffOffset = (toPosition() - game.judo.toPosition()).toOffset();
//    print("my var >> ${diffOffset.direction}");
    var dis = Random().nextDouble() * 10 * (2 * JoGame.unit);
    if (diffOffset.dx.abs() > JoGame.unit * 7 ||
        diffOffset.dy.abs() > JoGame.unit * 3) {
      // x,y方向都太遠
      newPos =
          Position.fromOffset(Offset.fromDirection(diffOffset.direction, dis));
    } else {
      newPos = Position.fromOffset(
          Offset.fromDirection(Random().nextDouble() * 3.1, dis));
    }
    return newPos;
  }

  @override
  void update(double dt) {
    if (!loaded()) return;

    countdown.update(dt);

    if (countdown.isFinished()) {
      toDestroy = true;
    }

//      if (JoGame.walk) {
//        var target = toPosition().toOffset() + game.mapMoveStep;
//        var newOffset = Offset.lerp(toPosition().toOffset(), target, dt);
//        setByPosition(Position.fromOffset(newOffset));
//      }

    renderFlipX = isLeftDir;

    if (toPosition().distance(game.judo.toPosition()) < 1) {
      nextPosition();
    }

    _flareAnimation.update(dt);
  }

  @override
  void render(Canvas canvas) {
    prepareCanvas(canvas);
    if (!loaded()) return;

    _flareAnimation.render(canvas, x: 0, y: 0);

    canvas.drawRect(hitRect, debugPaint);
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
