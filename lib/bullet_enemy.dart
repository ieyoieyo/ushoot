import 'dart:ui';

import 'package:flame/components/component.dart';
import 'package:flame/position.dart';
import 'package:ushoot/JoGame.dart';

class Bullet extends SpriteComponent {
  final JoGame game;
  double dir;

  double get speed => JoGame.unit * 1.8;
  bool toDestroy = false;

  Bullet(this.game, Position position) : super.square(22.0, "player_1.png") {
    setByPosition(position);

    var juCenter = game.judo.toRect().center;
    var diffOffset =
        juCenter - Offset(width / 2, height / 4) - toPosition().toOffset();
    dir = diffOffset.direction;
  }

  @override
  void update(double t) {
    super.update(t);

    //子彈移動
    var dis = speed * t;
    var step = Offset.fromDirection(dir, dis);
    var newPos = toPosition().toOffset() + step;
    setByPosition(Position.fromOffset(newPos));

    if (!game.screenRect.contains((toPosition() - game.camera).toOffset())) {
      toDestroy = true;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
  }

  @override
  int priority() {
    return 9999; //永遠在最上層！
  }

  @override
  bool destroy() {
    return toDestroy;
  }
}
