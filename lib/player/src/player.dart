import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:player_test/main.dart';
import 'package:player_test/player/src/touch_tools.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock/wakelock.dart';

class IPlayer extends StatefulWidget {
  /// Videoni yuqori qismida chiqadigan nomi
  /// ushbu nom shu video qayta ko'rilganda pozitsiyasini saqlab qolish uchun ishlatilishi ham mumkin
  final String title;
  final Color primaryColor;
  final Color secondaryColor;
  const IPlayer({
    super.key,
    required this.title,
    this.primaryColor = Colors.red,
    this.secondaryColor = Colors.grey,
  });

  @override
  State<IPlayer> createState() => _IPlayerState();
}

class _IPlayerState extends State<IPlayer> {
  late VideoPlayerController playerController;

  /// Video qaysi soniyasi qo'yilayotganini boshqaradi
  final StreamController<double> _positionController =
      StreamController<double>.broadcast();
  Stream<double> get _positionStream => _positionController.stream;

  /// Markazdagi widgetlarni boshqaradi
  final StreamController<bool> _centerWidgetsController =
      StreamController<bool>.broadcast();
  Stream<bool> get _centerWidgetsStream => _centerWidgetsController.stream;

  /// Sliderni boshqaradi
  final StreamController<double> _sliderController =
      StreamController<double>.broadcast();
  Stream<double> get _sliderStream => _sliderController.stream;

  /// Sliderni pozitsiyasini anglatadi.
  double _sliderValue = 0;

  /// Agar true bo'lsa slider ayni vaqtda barmoq bilan surilmoqdaligini anglatadi.
  bool _isSliderTouch = false;

  /// Pastki va yuqoridagi hususiyatlarni ko'rinish
  bool _isBlocked = false;

  /// boshqaruv widgetlarini yashirilishini boshqaradi
  final StreamController<bool> _hideController = StreamController<bool>();
  Stream<bool> get _hideStream => _hideController.stream;

  /// vidgetlari ko'rinmaydigan holatgacha qolgan vaqt (sekund)
  int _toHideTimeOut = 8;

  /// vidgetlarning yopilishini boshqaradi.
  Timer? _hideTimer;

  @override
  void initState() {
    Wakelock.enable();
    _setPlayer();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: OrientationBuilder(builder: (context, orientation) {
        return Stack(
          children: playerController.value.isInitialized
              ? [
                  GestureDetector(
                    onTapDown: (details) => unHide(),
                    onLongPressStart: (details) => playerController.pause(),
                    onLongPressEnd: (details) => playerController.play(),
                    child: InteractiveViewer(
                      minScale: 1,
                      maxScale: 1.6,
                      constrained: true,
                      panEnabled: false,
                      scaleEnabled: orientation == Orientation.landscape,
                      child: Center(
                        child: SizedBox(
                          width: 600.w,
                          height: 600.w / playerController.value.aspectRatio,
                          child: Stack(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: AspectRatio(
                                      aspectRatio:
                                          playerController.value.aspectRatio,
                                      child: VideoPlayer(playerController),
                                    ),
                                  ),
                                ],
                              ),
                              if (!_isBlocked)
                                Center(
                                  child: StreamBuilder<bool>(
                                      stream: _centerWidgetsStream,
                                      builder: (context, snapshot) {
                                        if (_toHideTimeOut <= 0) {
                                          return const SizedBox();
                                        }
                                        return Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                int seconds = playerController
                                                    .value.position.inSeconds;
                                                if (seconds > 10) {
                                                  seconds -= 10;
                                                  playerController.seekTo(
                                                      Duration(
                                                          seconds: seconds));
                                                }
                                                unHide();
                                              },
                                              child: FaIcon(
                                                FontAwesomeIcons.backward,
                                                color: Colors.white,
                                                size: 32.o,
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.all(16.o),
                                              child: GestureDetector(
                                                onTap: () {
                                                  if (playerController
                                                      .value.isPlaying) {
                                                    playerController.pause();
                                                  } else {
                                                    playerController.play();
                                                  }
                                                  unHide();
                                                },
                                                child: FaIcon(
                                                  playerController
                                                          .value.isPlaying
                                                      ? FontAwesomeIcons.pause
                                                      : FontAwesomeIcons.play,
                                                  color: Colors.white,
                                                  size: 48.o,
                                                ),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                int seconds = playerController
                                                    .value.position.inSeconds;
                                                if (seconds <
                                                    playerController
                                                            .value
                                                            .duration
                                                            .inSeconds -
                                                        10) {
                                                  seconds += 10;
                                                  playerController.seekTo(
                                                      Duration(
                                                          seconds: seconds));
                                                }
                                                unHide();
                                              },
                                              child: FaIcon(
                                                FontAwesomeIcons.forward,
                                                color: Colors.white,
                                                size: 32.o,
                                              ),
                                            ),
                                          ],
                                        );
                                      }),
                                ),
                              if (!_isBlocked)
                                TouchTools(
                                  height: 600.w /
                                      playerController.value.aspectRatio,
                                  playerController: playerController,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  StreamBuilder<bool>(
                      stream: _hideStream,
                      builder: (context, snapshot) {
                        if (snapshot.data ?? false) {
                          return const SizedBox();
                        }
                        return SafeArea(
                          bottom: false,
                          child: Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  IconButton(
                                    onPressed: () => Navigator.pop(context),
                                    icon: FaIcon(
                                      FontAwesomeIcons.arrowLeft,
                                      color: Colors.white,
                                      size: 22.o,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      widget.title,
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                        fontSize: 16.o,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 20.o,
                                  ),
                                ],
                              ),
                              const Spacer(),
                              StreamBuilder<double>(
                                stream: _sliderStream,
                                builder: (context, snapshot) {
                                  if (_isBlocked) {
                                    return const SizedBox();
                                  }
                                  return Slider(
                                    value: _sliderValue,
                                    activeColor: widget.primaryColor,
                                    secondaryActiveColor: widget.secondaryColor,
                                    inactiveColor:
                                        widget.secondaryColor.withOpacity(0.5),
                                    onChangeStart: (value) =>
                                        _isSliderTouch = true,
                                    onChangeEnd: (newValue) {
                                      _sliderValue = newValue;
                                      playerController
                                          .seekTo(Duration(
                                              milliseconds: (playerController
                                                          .value
                                                          .duration
                                                          .inMilliseconds *
                                                      _sliderValue)
                                                  .toInt()))
                                          .then((value) =>
                                              _isSliderTouch = false);
                                    },
                                    onChanged: (double newValue) {
                                      _sliderValue = newValue;
                                      _sliderController.sink.add(_sliderValue);
                                      unHide();
                                    },
                                  );
                                },
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                  left: 16.o,
                                  right: 8.o,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: _isBlocked
                                      ? [
                                          const Spacer(),
                                          _tool(
                                            onTap: () => setState(() {
                                              _isBlocked = !_isBlocked;
                                              unHide();
                                            }),
                                            icon: FontAwesomeIcons.lockOpen,
                                          ),
                                        ]
                                      : [
                                          StreamBuilder<double>(
                                              stream: _positionStream,
                                              builder: (context, snapshot) {
                                                return Text(
                                                  '${_videoPosition(playerController.value.position)} / ${_videoPosition(playerController.value.duration)}',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 16.o,
                                                    color: Colors.white,
                                                  ),
                                                );
                                              }),
                                          const Spacer(),
                                          _tool(
                                            onTap: () => setState(() {
                                              _isBlocked = !_isBlocked;
                                              unHide();
                                            }),
                                            icon: FontAwesomeIcons.lock,
                                          ),
                                          _tool(
                                            onTap: () {
                                              unHide();
                                            },
                                            icon: FontAwesomeIcons.gaugeHigh,
                                          ),
                                        ],
                                ),
                              ),
                              if (Platform.isIOS)
                                SizedBox(
                                  height: 12.o,
                                )
                            ],
                          ),
                        );
                      }),
                ]
              : [
                  Center(
                    child: CircularProgressIndicator(
                      backgroundColor: widget.primaryColor,
                    ),
                  )
                ],
        );
      }),
    );
  }

  @override
  void dispose() {
    super.dispose();
    playerController.dispose();
    if (_hideTimer != null) {
      _hideTimer!.cancel();
    }
  }

  void _setPlayer() async {
    bool playingValue = false, buferingValue = false;
    playerController = VideoPlayerController.asset('assets/raw/video.mp4')
      ..initialize().then((_) {
        playerController.play();
        playerController.setLooping(true);
        playerController.addListener(() {
          _positionController.sink.add(_sliderValue);
          if (playerController.value.isCompleted) {
            Wakelock.disable();
          }
          if (!_isSliderTouch &&
              !playerController.value.isBuffering &&
              playerController.value.duration != Duration.zero) {
            _sliderValue = playerController.value.position.inMilliseconds /
                playerController.value.duration.inMilliseconds;
            _sliderController.sink.add(_sliderValue);
          }
          if (playerController.value.isPlaying != playingValue ||
              playerController.value.isBuffering != buferingValue) {
            playingValue = playerController.value.isPlaying;
            buferingValue = playerController.value.isBuffering;
            _centerWidgetsController.sink.add(playingValue);
          }
        });
        unHide();
        setState(() {});
      });
  }

  void unHide() {
    if (_toHideTimeOut == 0 || _hideTimer == null) {
      if (_hideTimer != null) {
        _hideTimer!.cancel();
      }
      _hideController.sink.add(false);
      _centerWidgetsController.sink.add(false);
      _toHideTimeOut = 8;
      _hideTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (playerController.value.isPlaying) {
          if (_toHideTimeOut <= 0) {
            _hideTimer!.cancel();
            _hideTimer = null;
            _hideController.sink.add(true);
            _centerWidgetsController.sink.add(true);
          } else {
            _toHideTimeOut--;
          }
        }
      });
    } else {
      _toHideTimeOut = 8;
    }
  }
}

class _tool extends StatelessWidget {
  final Function() onTap;
  final IconData icon;
  const _tool({required this.onTap, required this.icon});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.only(
          left: 10.o,
          right: 10.o,
          bottom: 10.o,
        ),
        color: Colors.transparent,
        child: FaIcon(
          icon,
          size: 22.o,
          color: Colors.white,
        ),
      ),
    );
  }
}

String _videoPosition(Duration duration) {
  final hours = _toDigits(duration.inHours);
  final minutes = _toDigits(duration.inMinutes.remainder(60));
  final seconds = _toDigits(duration.inSeconds.remainder(60));
  return [if (duration.inHours > 0) hours, minutes, seconds].join(':');
}

String _toDigits(int n) => n.toString().padLeft(2, '0');
