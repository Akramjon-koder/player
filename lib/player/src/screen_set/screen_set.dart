import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:player_test/main.dart';
import 'package:screen_protector/screen_protector.dart';
import 'package:video_player/video_player.dart';

import 'screen_set_options.dart';

class ScreenSet extends StatefulWidget {
  ///ushbu malumotlar orqali boshqariladi
  final ScreenSetOptions options;

  /// agar ekran yozilishidan himoya qilish yoqilgan bo'lsa
  /// videoni to'xtatish uchun zarur
  final VideoPlayerController? playerController;

  const ScreenSet({
    super.key,
    this.playerController,
    required this.options,
  });

  @override
  State<ScreenSet> createState() => _SetLogoState();
}

class _SetLogoState extends State<ScreenSet> {
  late Timer timer;
  int time = 0;
  int positionIndex = 0;
  ValueNotifier<bool> isRecordingNotifier = ValueNotifier(false);
  late ValueNotifier<Alignment> positionNotifier;
  ValueNotifier<bool> isActiveNotifier = ValueNotifier(false);

  @override
  void initState() {
    // Logotip pozitsiyasi o'zgarishi vaqti (sekund)
    positionNotifier = ValueNotifier(widget.options.positions.isEmpty
        ? Alignment.topLeft
        : widget.options.positions.first);

    // agar ekranni himoya qilish kerak bo'lsa ushbu ekranni yozib olishdan saqlaydi
    if(widget.options.isScreenSecure){
      if (Platform.isAndroid) {
        FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
      }
    }

    // vaqtga bog'liq animatsiyani boshqariladi
    timer = Timer.periodic(const Duration(seconds: 1), (timer){
      if(time == widget.options.unActiveDuration + (2 * widget.options.activeDuration)){
        //barchasini boshidan boshlash
        time = 0;
      }
      if(time == 0){
        // logotip ko'rinishi
        isActiveNotifier.value = true;
      }else if(time == widget.options.activeDuration){
        // Logotip unActiv  bo'lishi
        isActiveNotifier.value = false;
      }else if(time == 2 * widget.options.activeDuration){
        //pozitsiyasini o'zgartirish
        if(widget.options.positions.length > 2){
          positionNotifier.value = widget.options
              .positions[positionIndex % widget.options.positions.length];
          positionIndex++;
        }
      }
      // ekranni har sekundda tekshirib
      // agar ekranni himoya qilish kerak bo'lsa
      // videoni to'xtatadi va ekranni qoraytiradi
      if(widget.options.isScreenSecure){
         ScreenProtector.isRecording().then((isRecording){
           isRecordingNotifier.value = isRecording;
           if( widget.playerController != null &&
               widget.options.pauseWhenRecording &&
               widget.playerController!.value.isPlaying
           ){
             widget.playerController!.pause();
           }
         });
      }
      time++;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ValueListenableBuilder(
          valueListenable: isRecordingNotifier,
          child: Container(
            color: Colors.black,
            padding: EdgeInsets.all(10.o),
            alignment: Alignment.center,
            child: Text(
              widget.options.screenRecordedText,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 15.o,
              ),
            ),
          ),
          builder: (context,value,child) => value ? child! : const SizedBox(),
        ),
        Padding(
          padding: EdgeInsets.all(10.o),
          child: ValueListenableBuilder(
            valueListenable: positionNotifier,
            builder: (context,value,child){
              return AnimatedAlign(
                alignment: value,
                duration: Duration(seconds: widget.options.unActiveDuration),
                child: ValueListenableBuilder(
                  valueListenable: isActiveNotifier,
                  builder: (context,isActive,child){
                    return AnimatedOpacity(
                      opacity: isActive ? widget.options.maxOpasity : widget.options.minOpasity,
                      duration: Duration(seconds: widget.options.activeDuration),
                      child: widget.options.logo,
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    timer.cancel();
    if (Platform.isAndroid) {
      FlutterWindowManager.clearFlags(FlutterWindowManager.FLAG_SECURE);
    }
    super.dispose();
  }
}
