import 'dart:math';
import 'dart:ui';

import 'package:flame/components/component.dart';
import 'package:flame/components/flare_component.dart';
import 'package:flame/flare_animation.dart';
import 'package:flame/game.dart';
import 'package:flame/gestures.dart';
import 'package:flame/position.dart';
import 'package:flame/sprite.dart';
import 'package:flame/svg.dart';
import 'package:flame/text_config.dart';
import 'package:flame/time.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:ushoot/judo.dart';
import 'package:ushoot/player.dart';

import 'bad01.dart';
import 'main.dart';

class JoGame extends BaseGame with PanDetector {
  bool isDebug = false;
  Player player;
  Size screenSize;
  static double unit;
  static Offset panStart, panEnd, dir_panStart, dir_panEnd;
  Paint shootLinePaint, bulletPaint;
  static bool drawLine = false;
  Rect screenRect;
  Judo judo;
  Bad01 bad01;
  static bool walk = false;

  final paint = Paint()..color = const Color(0xFFE5E5E5E5);

  JoGame() {
    player = Player(this);

    shootLinePaint = Paint()
      ..strokeWidth = 10.0
      ..color = Colors.white.withAlpha(100);

    bulletPaint = Paint()
      ..strokeWidth = bulletWidth
      ..color = Colors.yellow[800].withAlpha(210);

    init();
  }

  final TextConfig fpsTextConfig =
      const TextConfig(color: const Color(0xFFFFFFFF));

  SpriteComponent map;

  void init() {
    map = SpriteComponent.square(1300.0, "map.png")
      ..x = -220.0
      ..y = -285.0;
    add(map);

    bad01 = Bad01(this, "assets/flare/bad01.flr", "Walk");
    add(bad01);

    judo = Judo(this, "assets/flare/stupid.flr", "Idle");
    add(judo);

    add(player);
  }

  String _aa = "Look";

  get action {
    return _aa = _aa == "Look" ? "Jump" : "Look";
  }

  final double judoSpeed = 40.0;
  Offset shootLineStart, shootLineEnd, bulletStart, bulletEnd;
  double bulletSpeed = 22.0;
  double bulletDirection = 0;
  double bulletWidth = 18.0;

  Offset judoMoved;

  @override
  void update(double t) {
    super.update(t);
    countdown.update(t);

    if (drawLine) {
      var pOffset = panEnd - panStart;
      shootLineEnd =
          shootLineStart + Offset.fromDirection(pOffset.direction, 220.0);

      if (!bulletGo) bulletDirection = pOffset.direction;
    }

    if (bulletGo) {
      if (screenSize != null) {
        if (screenSize.contains(bulletStart)) {
          bulletStart += Offset.fromDirection(bulletDirection, bulletSpeed);
          bulletEnd = bulletStart + Offset.fromDirection(bulletDirection, 60.0);

          isHit();
        } else {
          bulletGo = false;
          bulletStart = Offset(screenSize.width / 2, screenSize.height / 2);
          lockShoot = false;
          bulletDirection = 0;
        }
      }
    }

    //移動Camera
    if (dir_panStart != null &&
        dir_panEnd != null &&
        ((judo.x - camera.x > judoCenterPos.dx + 1) ||
            (judo.y - camera.y > judoCenterPos.dy + 1))) {
//      print("judo Offset = ${judo.toPosition().toOffset()}");
      judoMoved =
          Offset(judo.x - judoCenterPos.dx, judo.y - judoCenterPos.dy);
      var newOffset = Offset.lerp(camera.toOffset(), judoMoved, t);
      camera.x = newOffset.dx;
      camera.y = newOffset.dy;
//      print("judoMoved= ${judoMoved}");
      var stepMove = Offset.fromDirection((panEnd-panStart).direction, judo.judoSpeed);
      var target = shootLineStart + stepMove;
      var aa = Offset.lerp(shootLineStart, target, t);
      shootLineStart = aa;
//      shootLineStart = Offset.lerp(shootLineStart, screenRect.center+judoMoved, t);
    }

    if (walk) {

//      var dOffset = dir_panStart - dir_panEnd;
//      judo.dir = dOffset.direction;
//      judo.toWalk();
//
//      mapMoveStep = Offset.fromDirection(dOffset.direction, judoSpeed);
//      var target = map.toPosition().toOffset() + mapMoveStep;
//      var newOffset = Offset.lerp(map.toPosition().toOffset(), target, t);
//      map.setByPosition(Position.fromOffset(newOffset));
    } else {
//      judo.toIdle();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    if (drawLine) {
      var pOffset = panEnd - panStart;
      if (pOffset != Offset.zero) {
        canvas.drawLine(shootLineStart, shootLineEnd, shootLinePaint);
      }
    }

    if (bulletGo) {
      canvas.drawLine(bulletStart, bulletEnd, bulletPaint);

      if (isDebug) {
        canvas.drawPoints(
            PointMode.points,
            [bltHitPointA, bltHitPointB, bulletStart, bulletEnd],
            Paint()
              ..strokeWidth = 3.0
              ..color = Colors.lightGreenAccent);
      }
    }

    if (isDebug && !bad01.isDead) {
      canvas.drawRect(bad01.hitRect,
          Paint()..color = Colors.lightGreenAccent.withAlpha(200));
    }

  }

  Offset judoCenterPos; //主角置中時，主角的Position

  @override
  void resize(Size size) {
    this.screenSize = size;
    unit = screenSize.height / 9;

    super.resize(size);
//
//    judo.width = judo.height = unit;
//    judo.init(unit * 1.2, unit * 1.2);
//    print("unit = $unit, judo.width = ${judo.width}");
    judo.x = (screenSize.width - judo.width) / 2;
    judo.y = (screenSize.height - judo.height) / 2;
    judoCenterPos = Offset(judo.x, judo.y);
    bad01.x = 480.0;
    bad01.y = 20.0;
    screenRect = Rect.fromLTWH(0.0, 0.0, screenSize.width, screenSize.height);
    shootLineStart = screenRect.center;
//    shootLineStart = Offset(judo.x + judo.width / 2, judo.y + judo.height / 2);

    bulletStart = Offset(screenSize.width / 2, screenSize.height / 2);
  }

  Offset bltHitPointA, bltHitPointB;

  void isHit() {
    bltHitPointA = bulletEnd +
        Offset.fromDirection(bulletDirection + pi / 2, bulletWidth / 2);
    bltHitPointB = bulletEnd +
        Offset.fromDirection(bulletDirection - pi / 2, bulletWidth / 2);
    [bulletEnd]..forEach((offset) {
        if (bad01.hitRect.contains(offset)) {
          print("HIT");
          bad01.toDead();
        }
      });
//    print("a = $a,,, b = $b");
  }

//  @override
//  void onTapDown(TapDownDetails details) {
//    print("onTapDown");
//    panStart = details.globalPosition;
//    panEnd = panStart;
//  }

  @override
  void onPanDown(DragDownDetails details) {
    print("__onPanDown");
    if (details.globalPosition.dx > screenSize.width / 2) {
      panEnd = details.globalPosition;
      panStart = details.globalPosition;
    } else {
      dir_panEnd = details.globalPosition;
      dir_panStart = details.globalPosition;
    }
  }

//
//  @override
//  void onPanStart(DragStartDetails details) {
//    print("___onPanStart");
//    if (details.globalPosition.dx > screenSize.width / 2) {
//      panEnd = details.globalPosition;
//      panStart = details.globalPosition;
//    } else {
//      dir_panEnd = details.globalPosition;
//      dir_panStart = details.globalPosition;
//    }
//  }

//  @override
//  void onPanUpdate(DragUpdateDetails details) {
//    if (details.globalPosition.dx > screenSize.width / 2) {
//      panEnd = details.globalPosition;
//      drawLine = true;
//    } else {
//      dir_panEnd = details.globalPosition;
//      walk = true;
//    }
//  }
//
//  @override
//  void onPanEnd(DragEndDetails details) {
//    print("onPanEnd");
//    if (drawLine) {
//      drawLine = false;
//      isAnimSwitched = false;
//    } else if (walk) {
//      walk = false;
////      dir_panStart = dir_panEnd = null;
//    }
//  }
//
//  @override
//  void onPanCancel() {
//    print("onPanCancel");
//    if (drawLine) {
//      drawLine = false;
//    } else if (walk) {
//      walk = false;
////      dir_panStart = dir_panEnd = null;
//    }
//  }
  var shootDrag = _DragHandler(shoot_onDragUpdate, shoot_onDragEnd);
  var moveDrag = _DragHandler(move_onDragUpdate, move_onDragEnd);

  Drag input(Offset offset) {
    print("offset.dx = ${offset.dx}");
    if (offset.dx < screenSize.width / 2) {
      return moveDrag;
    } else {
      return shootDrag;
    }
  }

  static GestureDragUpdateCallback move_onDragUpdate =
      (DragUpdateDetails details) {
//    print("move onUpdate");
    dir_panEnd = details.globalPosition;
    walk = true;
  };
  static GestureDragEndCallback move_onDragEnd = (DragEndDetails details) {
    print("move onEnd");
    walk = false;
  };

  static GestureDragUpdateCallback shoot_onDragUpdate =
      (DragUpdateDetails details) {
//    print("shoot onUpdate");
    panEnd = details.globalPosition;
    drawLine = true;
  };
  static GestureDragEndCallback shoot_onDragEnd = (DragEndDetails details) {
    print("shoot onEnd");
//    if (drawLine) {
    drawLine = false;

    if (!lockShoot) countdown.start();
//    }
  };

  static bool bulletGo = false;
  static bool lockShoot = false;
  static final Timer countdown = Timer(.06, callback: () {
    bulletGo = true;
    lockShoot = true;
  });

  @override
  bool debugMode() => isDebug;
}

class _DragHandler extends Drag {
  _DragHandler(onUpdate, onEnd) {
    this.onEnd = onEnd;
    this.onUpdate = onUpdate;
  }

  GestureDragUpdateCallback onUpdate;
  GestureDragEndCallback onEnd;

  @override
  void update(DragUpdateDetails details) {
    onUpdate(details);
  }

  @override
  void end(DragEndDetails details) {
    onEnd(details);
  }

  @override
  void cancel() {
    print("Drag Canceled");
  }
}
