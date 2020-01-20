import 'dart:math';
import 'dart:ui';

import 'package:flame/animation.dart' as flameAnim;
import 'package:flame/animation.dart';
import 'package:flame/components/animation_component.dart';
import 'package:flame/position.dart';
import 'package:flame/sprite.dart';
import 'package:flame/time.dart';
import 'package:flutter/material.dart';
import 'package:ushoot/JoGame.dart';

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

  flameAnim.Animation explodeAnim;

  void init() {
    width = height = wh;
    animation = flameAnim.Animation.sequenced("bad.png", 10,
        textureWidth: 180.0, textureHeight: 180.0, stepTime: 0.125);
    newPos = nextPosition();
    hitRect = Rect.fromCenter(
      center: Offset(
        width / 2 + width / 30,
        height / 2 + height / 20,
      ),
      width: width * 4 / 9,
      height: height * 2 / 7,
    );
    explodeAnim = flameAnim.Animation.empty()..loop=false;
    explodeAnim.frames = List<Frame>(90);
    for (var i = 0; i < 90; i++) {
      var row = i ~/ 8;
      final Sprite sprite = Sprite(
        "8.png",
        x:  (i%8) * 64.0,
        y: row * 48.0,
        width: 64.0,
        height: 48.0,
      );
      explodeAnim.frames[i] = Frame(sprite, .0125);
    }
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
    return (y + width * 78 / 100).toInt();
  }

  @override
  void update(double dt) {
    if (!loaded()) return;

    if (isDead) deadAnimCountdown.update(dt);

    if (deadAnimCountdown.isFinished()) {
      toDestroy = true;
    }

    renderFlipX = isLeftDir;

    //走路
    if (!isDead){
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

    super.update(dt);
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
