import 'package:flame/components/component.dart';
import 'package:flame/sprite.dart';
import 'package:ushoot/JoGame.dart';

class Player extends SpriteComponent {
  final JoGame game;

  Player(this.game) : super.fromSprite(36.0, 36.0, Sprite("player_1.png")){
    this.x = 120.0;
    this.y = 110.0;
  }

  bool goLeft = false;
  double speed = 30.0;

  @override
  void update(double t) {
    super.update(t);

    var isContain = game.screenRect.contains((toPosition()-game.camera).toOffset());
    if (isContain != null) {
      if (goLeft) {
        if (isContain)
          x -= speed * t;
        else {
          goLeft = false;
          x += speed * t;
        }
      } else {
        if (isContain)
          x += speed * t;
        else {
          goLeft = true;
          x -= speed * t;
        }
      }

    }


  }


}
