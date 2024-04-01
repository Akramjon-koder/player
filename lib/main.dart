import 'package:flutter/material.dart';
import 'package:player_test/player/src/player.dart';

double height = 1, width = 1, arifmethic = 1; //size variables

extension ExtSize on num {
  double get h {
    return this * height;
  }

  double get w {
    return this * width;
  }

  double get o {
    return this * arifmethic;
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height / 600;
    width = MediaQuery.of(context).size.width / 600;
    arifmethic = (height + width) / 2;
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const IPlayer(
        title: 'Flutter Demo IPlayer',
        sourceUrl:
            'https://basmalaplay.uz/uploads/media/disk2/stream/3216/ff284f5f9884fca37f916e96b7d4997f/185a45e0d753ece5c6fa20ab69fecd46.m3u8',
      ),
    );
  }
}
