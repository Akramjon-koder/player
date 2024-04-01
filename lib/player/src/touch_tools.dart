import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:video_player/video_player.dart';

class TouchTools extends StatefulWidget {
  final double height;
  final VideoPlayerController playerController;
  const TouchTools({
    super.key,
    this.height = 100,
    required this.playerController,
  });

  @override
  State<TouchTools> createState() => _TouchToolsState();
}

class _TouchToolsState extends State<TouchTools> {
  bool? isLeftAnimating;
  Timer? timer;
  final StreamController<int> leftController = StreamController<int>();
  final StreamController<int> rightController = StreamController<int>();
  int tick = 0;
  double brightness = 0.5;
  final screenBrightness = ScreenBrightness();

  @override
  void dispose() {
    cancelTimer();
    super.dispose();
  }

  @override
  void initState() {
    try {
      screenBrightness.current.then((value) => brightness = value);
    } catch (e) {
      print(e);
      throw 'Failed to get current brightness';
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        GestureDetector(
          onLongPressStart: (details) => startTimer(true),
          onLongPressEnd: (details) => cancelAnimating(),
          onVerticalDragUpdate: (details) =>
              setBrightness(details.primaryDelta ?? 0),
          child: StreamBuilder<int>(
              stream: leftController.stream,
              builder: (context, snapshot) {
                return Container(
                  width: widget.height / 2,
                  height: widget.height,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(widget.height),
                      bottomRight: Radius.circular(widget.height),
                    ),
                    color: Colors.white
                        .withOpacity(isLeftAnimating == null ? 0 : 0.4),
                  ),
                  child: Center(
                    child: Transform.rotate(
                      angle: pi,
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedOpacity(
                            opacity:
                                isLeftAnimating != true || tick < 4 ? 0 : 1,
                            duration: const Duration(milliseconds: 300),
                            child: play,
                          ),
                          AnimatedOpacity(
                            opacity:
                                isLeftAnimating != true || tick > 2 && tick < 6
                                    ? 0
                                    : 1,
                            duration: const Duration(milliseconds: 300),
                            child: play,
                          ),
                          AnimatedOpacity(
                            opacity:
                                isLeftAnimating != true || tick > 3 && tick < 7
                                    ? 0
                                    : 1,
                            duration: const Duration(milliseconds: 300),
                            child: play,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
        ),
        const Spacer(),
        GestureDetector(
          onLongPressStart: (details) => startTimer(false),
          onLongPressEnd: (details) => cancelAnimating(),
          onVerticalDragUpdate: (details) =>
              setBrightness(details.primaryDelta ?? 0),
          child: StreamBuilder<int>(
              stream: rightController.stream,
              builder: (context, snapshot) {
                return Container(
                  width: widget.height / 2,
                  height: widget.height,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(widget.height),
                      bottomLeft: Radius.circular(widget.height),
                    ),
                    color: Colors.white
                        .withOpacity(isLeftAnimating == null ? 0 : 0.4),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedOpacity(
                          opacity: isLeftAnimating != false || tick < 4 ? 0 : 1,
                          duration: const Duration(milliseconds: 300),
                          child: play,
                        ),
                        AnimatedOpacity(
                          opacity:
                              isLeftAnimating != false || tick > 2 && tick < 6
                                  ? 0
                                  : 1,
                          duration: const Duration(milliseconds: 300),
                          child: play,
                        ),
                        AnimatedOpacity(
                          opacity:
                              isLeftAnimating != false || tick > 3 && tick < 7
                                  ? 0
                                  : 1,
                          duration: const Duration(milliseconds: 300),
                          child: play,
                        ),
                      ],
                    ),
                  ),
                );
              }),
        ),
      ],
    );
  }

  void setBrightness(double delta) {
    double newBrightness = brightness - (delta / 100);
    if (newBrightness > 1) {
      newBrightness = 1;
    }
    if (newBrightness < 0) {
      newBrightness = 0;
    }
    try {
      screenBrightness
          .setScreenBrightness(newBrightness)
          .then((value) => brightness = newBrightness);
    } catch (e) {
      print(e);
      throw 'Failed to get current brightness';
    }
  }

  void startTimer(bool leftAnimating) {
    if (isLeftAnimating != null) {
      return;
    }
    isLeftAnimating = leftAnimating;
    if (isLeftAnimating!) {
      leftController.sink.add(tick);
    } else {
      rightController.sink.add(tick);
    }
    timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (tick > 5) {
        tick = 0;
      }
      int seconds = widget.playerController.value.position.inSeconds;
      if (isLeftAnimating!) {
        if (seconds > 10) {
          seconds -= 10;
          if (tick == 1) {
            widget.playerController.seekTo(Duration(seconds: seconds));
          }
        }
        leftController.sink.add(tick);
      } else {
        if (seconds < widget.playerController.value.duration.inSeconds - 10) {
          seconds += 10;
          if (tick == 1) {
            widget.playerController.seekTo(Duration(seconds: seconds));
          }
        }
        rightController.sink.add(tick);
      }
      tick++;
    });
  }

  void cancelAnimating() {
    if (isLeftAnimating == null) {
      return;
    }
    cancelTimer();
    isLeftAnimating = null;
    leftController.sink.add(tick);
    rightController.sink.add(tick);
  }

  void cancelTimer() {
    if (timer != null) {
      timer!.cancel();
    }
  }

  Widget get play => const FaIcon(
        FontAwesomeIcons.play,
        size: 15,
        color: Colors.white,
      );
}
