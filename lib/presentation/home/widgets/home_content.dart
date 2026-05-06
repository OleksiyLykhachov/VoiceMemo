import 'package:flutter/material.dart';

import 'home_background.dart';
import 'records.dart';

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return HomeBackground(
      child: LayoutBuilder(
        builder: (context, constraints) {
          const padding = 16.0;
          final cardRadius = constraints.maxWidth - padding * 2;

          return Padding(
            padding: const EdgeInsets.all(padding),
            child: Records(cardRadius: cardRadius),
          );
        },
      ),
    );
  }
}
