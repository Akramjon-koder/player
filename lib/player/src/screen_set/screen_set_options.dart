import 'package:flutter/material.dart';

class ScreenSetOptions{
  /// Logotip boradigan joylar
  final List<Alignment> positions;

  /// faol emas bo'lish vaqti (sekund)
  final int unActiveDuration;

  /// faol emas bo'lish vaqti (sekund)
  final int activeDuration;

  /// faol bo'lgan vaqtdagi maksimal ko'rinishi
  /// 0 dan katta va 1 dan kichik qiymatlarni qabul qiladi
  final double maxOpasity;

  /// faol bo'lgan vaqtdagi minimal shaffofligi
  /// 0 dan katta va 1 dan kichik qiymatlarni qabul qiladi
  final double minOpasity;

  /// ekranni yozib olishdan himoya qilish
  final bool isScreenSecure;

  /// agar ekran yozib olinayotgan bo'lsa video'ni to'xtatish
  final bool pauseWhenRecording;

  /// Ekran yozib olinayotganda chiqadigan text
  final String screenRecordedText;

  /// Ekran yozib olinayotganda chiqadigan text
  final Widget logo;

  const ScreenSetOptions({
    this.positions = const[],
    this.activeDuration = 1,
    this.unActiveDuration = 59,
    this.maxOpasity = 0.9,
    this.minOpasity = 0.1,
    this.isScreenSecure = false,
    this.pauseWhenRecording = false,
    this.screenRecordedText = '',
    this.logo = const SizedBox(),
  }):
        assert(activeDuration >= 1),
        assert(unActiveDuration >= 1),
        assert(minOpasity >= 0),
        assert(maxOpasity >= minOpasity);

}