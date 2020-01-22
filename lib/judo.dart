import 'dart:math';
import 'dart:ui';

import 'package:flame/components/component.dart';
import 'package:flame/flare_animation.dart';
import 'package:flame/position.dart';
import 'package:ushoot/JoGame.dart';

///主角
///用 FlareComponent 來改的 Class。因為 FlareComponent 不能切換動畫(updateAnimation)
class Judo extends PositionComponent {
  FlareAnimation _flareAnimation;
  final JoGame game;

  double get speed => JoGame.unit;

  double get judoSize {
    return JoGame.unit * 2.4;
  }

  String fileName, animation;
  bool toJump = false;
  double dir;

  @override
  int priority() {
    return (y + width * 270 / 368).toInt();
  }

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

    hitRect = Rect.fromCenter(
        center: toRect().center, width: width / 2, height: height / 3);
  }

  Rect hitRect;

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

    renderFlipX = isLeftDir;

    if (JoGame.walk) {
      var dOffset = JoGame.dir_panEnd - JoGame.dir_panStart;
      dir = dOffset.direction;
      toWalk();

      var stepMove = Offset.fromDirection(dir, speed * dt);
      var target = toPosition().toOffset() + stepMove;
      if (target.dx > game.map.x &&
          target.dx < game.map.x + game.map.width - width) {
        x = target.dx;
      }
      if (target.dy > game.map.y &&
          target.dy < game.map.y + game.map.height - height) {
        y = target.dy;
      }

//      setByPosition(Position.fromOffset(target));
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
    x = (size.width - width) / 2;
    y = (size.height - height) / 2;
    print("JUDO: unit = ${JoGame.unit}, judo.width = ${width}");
  }
}
