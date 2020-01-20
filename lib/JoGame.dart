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
import 'package:ushoot/enemy.dart';
import 'package:ushoot/joMap.dart';
import 'package:ushoot/judo.dart';
import 'package:ushoot/player.dart';
import 'package:ordered_set/ordered_set.dart';
import 'package:ordered_set/comparing.dart';

import 'bad01.dart';
import 'dodo.dart';

class JoGame extends BaseGame with PanDetector {
  bool isDebug = true;
  Player player;
  Size screenSize;
  static double unit; // S7 = 40.0
  static Offset panStart, panEnd, dir_panStart, dir_panEnd;
  Paint shootLinePaint, bulletPaint;
  static bool drawLine = false;
  Rect screenRect;
  Judo judo;
  Bad01 bad01;
  static bool walk = false;
  final paint = Paint()..color = const Color(0xFFE5E5E5E5);

  double get cameraSpeed => unit * .86;

  set cameraSpeed(double value) => value;

  JoGame() {
    player = Player(this);

    shootLinePaint = Paint()
      ..strokeWidth = 10.0
      ..color = Colors.white.withAlpha(100);

    bulletPaint = Paint()
      ..strokeWidth = bulletWidth
      ..color = Colors.yellow[600].withAlpha(210);

    init();
  }

  final TextConfig fpsTextConfig =
      const TextConfig(color: const Color(0xFFFFFFFF));

  JoMap map;

  void init() {
    map = JoMap(this);
    add(map);

    bad01 = Bad01(this, "assets/flare/bad01.flr", "Walk");
//    add(bad01);
//    enemies.add(bad01);
    var dodo = Dodo(this)..setByPosition(Position(400, 130));
    add(dodo);
    enemies.add(dodo);

    judo = Judo(this, "assets/flare/stupid.flr", "Idle");
    add(judo);

//    add(player);

    spawnBad01Timer = Timer(5, repeat: true, callback: spawn);
    spawnBad01Timer.start();
  }

  Offset shootLineStart, shootLineEnd, bulletStart, bulletEnd;
  double bulletSpeed = 22.0;
  double bulletDirection = 0;
  double bulletWidth = 18.0;
  static bool bltJustStart = false;

  List<Enemy> enemies = [];

  @override
  void update(double t) {
    if (screenSize == null) return;

    //重加所有 components。為了解決 render priority() Y 值高的晚 render
    var list = components.toList();
    components.clear();
    components.addAll(list);

    super.update(t);

    countdown.update(t);
    spawnBad01Timer.update(t);

//    if ((judo.x - camera.x).abs() > 120.0 ||
//        (judo.y - camera.y).abs() > 100.0) {
//      cameraSpeed = unit * 4;
//    }
    //移動Camera
    if (dir_panStart != null &&
        dir_panEnd != null &&
        ((judo.x - camera.x > judoCenterPos.x + 1) ||
            (judo.x - camera.x < judoCenterPos.x - 1) ||
            (judo.y - camera.y > judoCenterPos.y + 1) ||
            (judo.y - camera.y < judoCenterPos.y - 1))) {
      var judoMoved = (judo.toPosition() - camera - judoCenterPos).toOffset();
      var step = Offset.fromDirection(judoMoved.direction, cameraSpeed * t);
      var newPosition = camera.toOffset() + step;
      camera.x = newPosition.dx;
      camera.y = newPosition.dy;

//      var newOffset = Offset.lerp(camera.toOffset(), judoMoved, t);
//      camera.x = newOffset.dx;
//      camera.y = newOffset.dy;

      //移動射線的起點(保持在主角的中心)
      var diff = judo.toPosition() - camera - judoCenterPos;
      shootLineStart = screenRect.center + diff.toOffset();
    }

    if (drawLine) {
      var pOffset = panEnd - panStart;
      shootLineEnd =
          shootLineStart + Offset.fromDirection(pOffset.direction, unit * 5.5);

      if (!bulletGo) bulletDirection = pOffset.direction;
    }

    if (bulletGo) {
      if (bltJustStart) {
        bltJustStart = false;
        bulletStart = shootLineStart;
      }
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
    if (screenSize == null) return;

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
            [bulletStart, bulletEnd],
            Paint()
              ..strokeWidth = 3.0
              ..color = Colors.lightGreenAccent);
      }
    }

    if (isDebug) {
      fpsTextConfig.render(canvas, fps(120).toString(), Position(0, 10));
    }
//    if (isDebug && !bad01.isDead) {
//      canvas.drawRect(bad01.hitRect,
//          Paint()..color = Colors.lightGreenAccent.withAlpha(200));
//    }
  }

  Position judoCenterPos; //主角置中時，主角的Position

  @override
  void resize(Size size) {
    this.screenSize = size;
    unit = screenSize.height / 9;
    print("unit = $unit, screenSize = $screenSize");
    super.resize(size);
//    judo.x = (screenSize.width - judo.width) / 2;
//    judo.y = (screenSize.height - judo.height) / 2;
    judoCenterPos = judo.toPosition();
    bad01.x = 480.0;
    bad01.y = 20.0;
    screenRect = Rect.fromLTWH(0.0, 0.0, screenSize.width, screenSize.height);
    shootLineStart = screenRect.center;

    bulletStart = Offset(screenSize.width / 2, screenSize.height / 2);
  }

  Random rdm = Random();

  void spawn() {
    if (enemies.length >= 6) return;

    double x, y;
    if (rdm.nextBool()) {
      //限制 x 方向在畫面外
      x = rdm.nextBool()
          ? camera.x + screenSize.width + 10
          : camera.x - unit * 2;
      y = rdm.nextDouble() * (camera.y + screenSize.height) - camera.y;
    } else {
      //限制 y 方向在畫面外
      x = rdm.nextDouble() * (camera.x + screenSize.width) - camera.x;
      y = rdm.nextBool()
          ? camera.y + screenSize.height + 10
          : camera.y - unit * 2;
    }
    var dodo = Dodo(this)..setByPosition(Position(x, y));
    add(dodo);
    enemies.add(dodo);
//    var bad = Bad01(this, "assets/flare/bad01.flr", "Walk");
//    bad.x = x;
//    bad.y = y;
//    add(bad);
//    enemies.add(bad);
  }

  Timer spawnBad01Timer;

  void isHit() {
    var deads = <Enemy>[];
    enemies.forEach((e) {
//      if (e is Dodo) {
      var rect = e.hitRect.translate(e.x - camera.x, e.y - camera.y);
      if (rect.contains(bulletEnd) || rect.contains(bulletStart)) {
        print("HIT");
        e.toDead();
        deads.add(e);
      }
//      }
    });
    deads.forEach((e) {
      enemies.remove(e);
    });
//    [bulletEnd].forEach((offset) {
//        var transToWorld =
//            bad01.hitRect.translate(bad01.x - camera.x, bad01.y - camera.y);
//        if (transToWorld.contains(offset)) {
//          print("HIT");
//          bad01.toDead();
//        }
//      });
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
//    print("offset.dx = ${offset.dx}");
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
//    print("move onEnd");
    walk = false;
  };

  static GestureDragUpdateCallback shoot_onDragUpdate =
      (DragUpdateDetails details) {
//    print("shoot onUpdate");
    panEnd = details.globalPosition;
    drawLine = true;
  };
  static GestureDragEndCallback shoot_onDragEnd = (DragEndDetails details) {
//    print("shoot onEnd");
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
    bltJustStart = true;
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
