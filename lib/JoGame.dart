import 'dart:ui';

import 'package:flame/components/component.dart';
import 'package:flame/components/flare_component.dart';
import 'package:flame/flare_animation.dart';
import 'package:flame/game.dart';
import 'package:flame/gestures.dart';
import 'package:flame/position.dart';
import 'package:flame/sprite.dart';
import 'package:flame/text_config.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:ushoot/judo.dart';
import 'package:ushoot/player.dart';

class JoGame extends BaseGame with PanDetector {
  Player player;
  Size screenSize;
  Offset panStart, panEnd, dir_panStart, dir_panEnd;
  Paint shootLinePaint;
  bool drawLine = false;
  Rect screenRect;
  Judo judo;
  bool walk = false;

  final paint = Paint()..color = const Color(0xFFE5E5E5E5);
  bool loaded = false;

  JoGame() {
    player = Player(this);

    shootLinePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 10.0;

    init();
  }

  FlareAnimation flareAnimation;
  final TextConfig fpsTextConfig =
      const TextConfig(color: const Color(0xFFFFFFFF));
  FlareComponent fla2;

  void init() async {
    flareAnimation = await FlareAnimation.load("assets/flare/stupid.flr");
    flareAnimation.updateAnimation("Look");
    flareAnimation.width = 220.0;
    flareAnimation.height = 220.0;

    judo = Judo(this, "assets/flare/stupid.flr", "Look", 100.0, 100.0);
    add(judo);

    fla2 = FlareComponent("assets/flare/stupid.flr", "Look", 100.0, 100.0);
//    fla2.x = (screenSize.width - fla2.width) / 2;
//    fla2.y = (screenSize.height - fla2.height) / 2;
//    add(fla2);
    loaded = true;

    add(player);
  }

  String _aa = "Look";

  get action {
    return _aa = _aa == "Look" ? "Jump" : "Look";
  }

  bool isAnimSwitched = false;

  @override
  void render(Canvas canvas) {
    if (loaded) {
      canvas.drawRect(
        Rect.fromLTWH(50, 50, flareAnimation.width, flareAnimation.height),
        paint,
      );

      flareAnimation.render(canvas, x: 50, y: 50);
    }

    super.render(canvas);

    if (drawLine) {
      var pOffset = panEnd - panStart;
      var _drawStart =
          Offset(fla2.x + fla2.width / 2, fla2.y + fla2.height / 2);

      canvas.drawLine(
          _drawStart,
          _drawStart + Offset.fromDirection(pOffset.direction, 220.0),
          shootLinePaint);
    }
  }

  @override
  void update(double t) {
    super.update(t);
    if (loaded) {
      flareAnimation.update(t);

      if (!isAnimSwitched) {
        isAnimSwitched = true;
        flareAnimation.updateAnimation(action);
        judo.toJump = true;
      }

      if (walk) {
        var dOffset = dir_panStart - dir_panEnd;
        judo.dir = dOffset.direction;
      } else {
//        judo.dir = 0.0;
      }
    }
  }

  @override
  void resize(Size size) {
    super.resize(size);
    this.screenSize = size;
    judo.x = (screenSize.width - fla2.width) / 2;
    judo.y = (screenSize.height - fla2.height) / 2;
    fla2.x = (screenSize.width - fla2.width) / 2;
    fla2.y = (screenSize.height - fla2.height) / 2;
    screenRect = Rect.fromLTWH(0.0, 0.0, screenSize.width, screenSize.height);
  }

  @override
  void onPanDown(DragDownDetails details) {}

  @override
  void onPanStart(DragStartDetails details) {
    if (details.globalPosition.dx > screenSize.width / 2) {
      panEnd = details.globalPosition;
      panStart = details.globalPosition;
    } else {
      dir_panEnd = details.globalPosition;
      dir_panStart = details.globalPosition;
    }
  }

  @override
  void onPanUpdate(DragUpdateDetails details) {
    if (details.globalPosition.dx > screenSize.width / 2) {
      panEnd = details.globalPosition;
      drawLine = true;
    } else {
      dir_panEnd = details.globalPosition;
      walk = true;
    }
  }

  @override
  void onPanEnd(DragEndDetails details) {
    print("onPanEnd");
    if (drawLine) {
      drawLine = false;
      isAnimSwitched = false;
    } else if (walk) {
      walk = false;
//      dir_panStart = dir_panEnd = null;
    }
  }

  @override
  void onPanCancel() {
    print("onPanCancel");
    if (drawLine) {
      drawLine = false;
    } else if (walk) {
      walk = false;
//      dir_panStart = dir_panEnd = null;
    }
  }

  Drag input(Offset event) {
    return _DragHandler(_onUpdate, _onEnd);
  }

  GestureDragUpdateCallback _onUpdate = (DragUpdateDetails details){
    print("KLJKJLDJLD");
  };
  GestureDragEndCallback _onEnd = (DragEndDetails details){};
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