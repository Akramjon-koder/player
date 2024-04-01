import 'package:flutter/material.dart';
import 'package:player_test/main.dart';

class PlayerSourseDialog extends StatelessWidget {
  final List<String> data;
  final Function(int index) onSelect;
  const PlayerSourseDialog(
      {super.key, required this.data, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 80.w),
        padding: EdgeInsets.symmetric(
          vertical: 5.o,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.black.withOpacity(0.8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: List<Widget>.generate(
            data.length,
            (index) => GestureDetector(
              onTap: () {
                onSelect(index);
                Navigator.pop(context);
              },
              child: Container(
                color: Colors.transparent,
                padding: EdgeInsets.symmetric(
                  vertical: 10.o,
                  horizontal: 20.o,
                ),
                child: Center(
                  child: Text(
                    data[index],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16.o,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
