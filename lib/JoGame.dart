import 'dart:ui';

import 'package:flame/components/component.dart';
import 'package:flame/components/flare_component.dart';
import 'package:flame/flare_animation.dart';
import 'package:flame/game.dart';
import 'package:flame/gestures.dart';
import 'package:flame/position.dart';
import 'package:flame/sprite.dart';
import 'package:flame/text_config.dart';
import 'package:flutter/material.dart';
import 'package:ushoot/player.dart';

class JoGame extends BaseGame with PanDetector {
  Player player;
  Size screenSize;
  Offset panStart, panEnd;
  Paint shootLinePaint;
  bool drawLine = false;

  final paint = Paint()..color = const Color(0xFFE5E5E5E5);
  bool loaded = false;

  JoGame() {
    player = Player(this);

    shootLinePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 10.0;

    _start();
  }

  FlareAnimation flareAnimation;
  final TextConfig fpsTextConfig =
      const TextConfig(color: const Color(0xFFFFFFFF));
  FlareComponent fla2;

  void _start() async {
    flareAnimation =
        await FlareAnimation.load("assets/flare/Liquid.flr");
    flareAnimation.updateAnimation("Demo");
    flareAnimation.width = 100.0;
    flareAnimation.height = 100.0;

    fla2 = FlareComponent("assets/flare/Liquid.flr", "Start",100.0,100.0);
    fla2.x = 250.0;
    fla2.y = 150.0;
    add(fla2);
    loaded = true;
    print("loaded: ${fla2.loaded()}");
    add(player);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    if (loaded) {
      canvas.drawRect(
        Rect.fromLTWH(50, 50, flareAnimation.width, flareAnimation.height),
        paint,
      );

      flareAnimation.render(canvas, x: 50, y: 50);
    }


    if (drawLine) canvas.drawLine(panStart, panEnd, shootLinePaint);
  }

  @override
  void update(double t) {
    super.update(t);
    if (loaded) {
      flareAnimation.update(t);

      fla2.x += 10*t;
    }
  }

  @override
  void resize(Size size) {
    super.resize(size);
    this.screenSize = size;
  }

  @override
  void onPanStart(DragStartDetails details) {
    panStart = details.globalPosition;
    drawLine = true;
  }

  @override
  void onPanDown(DragDownDetails details) {
    panStart = details.globalPosition;
    panEnd = panStart;
  }

  @override
  void onPanUpdate(DragUpdateDetails details) {
    panEnd = details.globalPosition;
  }

  @override
  void onPanEnd(DragEndDetails details) {
    drawLine = false;
  }

  @override
  void onPanCancel() {
    drawLine = false;
  }
}
