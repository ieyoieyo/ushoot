import 'dart:math';
import 'dart:ui';

import 'package:flame/components/component.dart';
import 'package:flame/flare_animation.dart';
import 'package:flame/position.dart';
import 'package:ushoot/JoGame.dart';

class Judo extends PositionComponent {
  FlareAnimation _flareAnimation;
  final JoGame game;
  final double judoSpeed = 40.0;

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
      return dir == 0 ? false : dir.abs() > pi / 2;
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
    if (!loaded()) return;

    if (isLeftDir) {
      renderFlipX = true;
    } else {
      renderFlipX = false;
    }

    if (JoGame.walk) {
      var dOffset = JoGame.dir_panEnd - JoGame.dir_panStart;
      dir = dOffset.direction;
      toWalk();

      var stepMove = Offset.fromDirection(dOffset.direction, judoSpeed * dt);
      var target = toPosition().toOffset() + stepMove;
      setByPosition(Position.fromOffset(target));
//      newOffset = Offset.lerp(toPosition().toOffset(), target, dt);
//      setByPosition(Position.fromOffset(newOffset));
    } else {
      toIdle();
    }

    _flareAnimation.update(dt);
  }

  Offset newOffset;

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
