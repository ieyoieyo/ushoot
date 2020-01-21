import 'package:flame/animation.dart';
import 'package:flame/sprite.dart';

class Util {
  static Animation atlasSprite(
      String imgPath,
      int totalFramesCount,
      int framesCountPerRow,
      double frameWidth,
      double frameHeight,
      double stepTime,
      [bool loop = true]) {
    var anim = Animation.empty()..loop = loop;

    anim.frames = List<Frame>(totalFramesCount);
    for (var i = 0; i < totalFramesCount; i++) {
      var row = i ~/ framesCountPerRow;
      final Sprite sprite = Sprite(
        imgPath,
        x: (i % framesCountPerRow) * frameWidth,
        y: row * frameHeight,
        width: frameWidth,
        height: frameHeight,
      );
      anim.frames[i] = Frame(sprite, stepTime);
    }
    return anim;
  }
}
