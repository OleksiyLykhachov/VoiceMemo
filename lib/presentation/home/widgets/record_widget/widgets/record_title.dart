import 'package:flutter/material.dart';

class RecordTitle extends StatelessWidget {
  final String text;
  const RecordTitle(
    this.text, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      maxLines: 2,
      style: TextStyle(
        letterSpacing: -1,
        fontSize: 21,
        height: 17 / 21,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
