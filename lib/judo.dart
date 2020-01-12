import 'dart:math';
import 'dart:ui';

import 'package:flame/components/component.dart';
import 'package:flame/flare_animation.dart';
import 'package:flame/position.dart';
import 'package:ushoot/JoGame.dart';

class Judo extends PositionComponent {
  FlareAnimation _flareAnimation;
  final JoGame game;

  double get judoSize {
    return JoGame.unit * 2.4;
  }

  String fileName, animation;
  bool toJump = false;
  double dir;

  Judo(this.game, this.fileName, this.animation) {
//    this.fileName = fileName;
//    this.animation = animation;
  }

  void init(double width, double height) {
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

  bool isWalk = false;

  void toWalk() {
    if (isWalk) return;
    _flareAnimation?.updateAnimation("Walk");
    isWalk = true;
  }

  void toIdle() {
    if (!isWalk) return;
    _flareAnimation?.updateAnimation("Idle");
    isWalk = false;
  }

  void updateAnim(String animName) {
    _flareAnimation?.updateAnimation(animName);
  }

  @override
  bool loaded() => _flareAnimation != null;

  @override
  void update(double dt) {
    if (_flareAnimation != null) {
      _flareAnimation.update(dt);

      if (isLeftDir) {
        renderFlipX = true;
      } else {
        renderFlipX = false;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    prepareCanvas(canvas);
    _flareAnimation.render(canvas, x: 0, y: 0);
  }

  @override
  void resize(Size size) {
    init(judoSize, judoSize);
    print("JUDO: unit = ${JoGame.unit}, judo.width = ${width}");
  }
}
