import 'package:flame/flame.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ushoot/JoGame.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.images.loadAll([
    "player_1.png",
  ]);
  await Flame.util.fullScreen();
  await Flame.util.setLandscape();
  var game = JoGame();
  runApp(game.widget);

//  Flame.util.addGestureRecognizer(PanGestureRecognizer());

  Flame.util.addGestureRecognizer(ImmediateMultiDragGestureRecognizer()
  ..onStart = (Offset event) => game.input(event));
}
