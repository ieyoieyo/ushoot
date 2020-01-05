import 'package:flame/components/component.dart';
import 'package:flame/sprite.dart';
import 'package:ushoot/JoGame.dart';

class Player extends SpriteComponent {
  final JoGame game;

  Player(this.game) : super.fromSprite(36.0, 36.0, Sprite("player_1.png")){
    this.x = 120.0;
    this.y = 120.0;
  }

  @override
  void update(double t) {
    super.update(t);

    x += 10.0 * t;
  }


}
