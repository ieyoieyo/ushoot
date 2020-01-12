import 'dart:math';
import 'dart:ui';

import 'package:flame/components/component.dart';
import 'package:flame/flare_animation.dart';
import 'package:ushoot/JoGame.dart';

///用 FlareComponent 來改的 Class。因為 FlareComponent 不能切換動畫(updateAnimation)
class Bad01 extends PositionComponent {
  FlareAnimation _flareAnimation;
  final JoGame game;
  final String fileName;
  String animName;
  bool isDead = false;
  double dir;

  double get bad01Size {
    return JoGame.unit * 2.4;
  }

  Rect get hitRect {
    Rect rr = toRect();
    return Rect.fromCenter(
            center: rr.center, width: rr.width / 6, height: rr.height / 7)
        .translate(0, rr.height / 15);
//    return Rect.fromLTRB(rr.left + width *2/5, rr.top + height * 4 / 9,
//        rr.right - width / 3, rr.bottom - width / 3);
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
      return dir == 0 ? false : dir.abs() < pi / 2;
  }

  void _jump() {
    _flareAnimation?.updateAnimation("Jump");
  }

  @override
  bool loaded() => _flareAnimation != null;

  @override
  void update(double dt) {
    if (_flareAnimation != null) {
      if (isDead) {
        isDead = false;
        _jump();
      }
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
    init(bad01Size, bad01Size);
  }
}
