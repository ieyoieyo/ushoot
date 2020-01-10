import 'dart:math';
import 'dart:ui';

import 'package:flame/components/component.dart';
import 'package:flame/flare_animation.dart';
import 'package:ushoot/JoGame.dart';

class Judo extends PositionComponent {
  FlareAnimation _flareAnimation;
  final JoGame game;
  bool toJump = false;
  double dir;

  Judo(this.game, String fileName, String animation, double width,
      double height) {
    this.width = width;
    this.height = height;

    FlareAnimation.load(fileName).then((loadedFlareAnimation) {
      _flareAnimation = loadedFlareAnimation;

      _flareAnimation.updateAnimation(animation);
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

  void _jump() {
    _flareAnimation?.updateAnimation("Jump");
  }

  @override
  bool loaded() => _flareAnimation != null;

  @override
  void render(Canvas canvas) {
    prepareCanvas(canvas);
    _flareAnimation.render(canvas, x: 0, y: 0);
  }

  @override
  void update(double dt) {
    if (_flareAnimation != null) {
      if (toJump) {
        toJump = false;
        _jump();
      }
      _flareAnimation.update(dt);

      if (isLeftDir) {
        renderFlipX = true;
      } else {
        renderFlipX = false;
      }
//      print("isLeft = $isLeftDir");
    }
  }
}
