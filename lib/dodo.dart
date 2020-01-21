import 'dart:math';
import 'dart:ui';

import 'package:flame/animation.dart' as flameAnim;
import 'package:flame/animation.dart';
import 'package:flame/components/animation_component.dart';
import 'package:flame/components/component.dart';
import 'package:flame/position.dart';
import 'package:flame/sprite.dart';
import 'package:flame/time.dart';
import 'package:flutter/material.dart';
import 'package:ushoot/JoGame.dart';
import 'package:ushoot/util.dart';

import 'enemy.dart';

class Dodo extends Enemy {
//  final JoGame game;
  bool isDead = false;
  bool toDestroy = false;
  double dir;
  Paint debugPaint = Paint()..color = Colors.lightGreenAccent.withAlpha(200);

//  Rect hitRect;
  Position newPos;

  double get wh => JoGame.unit * 1.74;

  double get speed => JoGame.unit * .4;

  Dodo(JoGame game) : super(game);

  void init() {
    width = height = wh;

//    animation = flameAnim.Animation.sequenced("bad.png", 10,
//        textureWidth: 180.0, textureHeight: 180.0, stepTime: 0.125);
    animation = Util.atlasSprite("bad.png", 10, 10, 180, 180, .125);

    newPos = nextPosition();

    hitRect = Rect.fromCenter(
      center: Offset(
        width / 2 + width / 30,
        height / 2 + height / 20,
      ),
      width: width * 4 / 9,
      height: height * 2 / 7,
    );

    time = DateTime.now().millisecondsSinceEpoch;
  }

  bool get isLeftDir {
    if (dir == null)
      return false;
    else
      return dir == 0 ? false : dir.abs() > pi / 2;
  }

  @override
  void toDead() {
    if (isDead) return;
    animation = explodeAnim;
    isDead = true;
    deadAnimCountdown.start();
  }

  Position nextPosition() {
    ///改為壞人與「螢幕中心點」的距離
    //要算壞人到主角的offset和角度，竟是用 (主角 - 壞人)？！不太懂！
    var diffOffset = (Position(game.camera.x + game.screenSize.width / 2,
                game.camera.y + game.screenSize.height / 2) -
            toPosition())
        .toOffset();
//    var diffOffset = (game.judo.toPosition() - toPosition()).toOffset();
    dir = diffOffset.direction;
    //每次走的距離，最短 unit/3, 最長 unit 的二又三分之一倍
    var dis = Random().nextDouble() * 2 * JoGame.unit + JoGame.unit / 3;
//    print("my var >> ${diffOffset}");
    if (diffOffset.dx.abs() > JoGame.unit * 7 ||
        diffOffset.dy.abs() > JoGame.unit * 3) {
//      print("x或y方向太遠");
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

  double get bulletSpeed => JoGame.unit * .1;

  double bulletDir;
  bool shootSetting = false;
  int time;

  @override
  int priority() {
    return (y + width * 78 / 100).toInt();
  }

  @override
  void update(double dt) {
    if (!loaded()) return;
    super.update(dt);

    if (isDead) deadAnimCountdown.update(dt);

    if (deadAnimCountdown.isFinished()) {
      toDestroy = true;
    }

    renderFlipX = isLeftDir;

    //走路
    if (!isDead) {
      var step = speed * dt;
      if (toPosition().distance(newPos) < step) {
        setByPosition(newPos);
        newPos = nextPosition();
      } else {
        var diff = newPos - toPosition();
        var move = Offset.fromDirection(diff.toOffset().direction, step);
        setByPosition(toPosition() + Position.fromOffset(move));
      }
    }

    if (!shootSetting &&
        (DateTime.now().millisecondsSinceEpoch - time) > 3000) {
      shootSetting = true;
      fireFlag = true;
    }
  }

  @override
  void render(Canvas canvas) {
    if (!loaded()) return;

    super.render(canvas);

//    if (game.isDebug) canvas.drawRect(hitRect, debugPaint);
  }

  @override
  bool destroy() {
    return toDestroy;
  }

  final Timer deadAnimCountdown = Timer(1.125);

  @override
  void resize(Size size) {
    init();
  }
}
