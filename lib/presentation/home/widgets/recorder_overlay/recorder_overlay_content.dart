import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voice_memos/presentation/presentation.dart';

import '../../bloc/bloc.dart';
import '../waveform/waveform.dart';

class RecorderOverlayContent extends StatelessWidget {
  final AnimationController controller;

  const RecorderOverlayContent({
    required this.controller,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FadeTransition(
        opacity: controller,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: controller,
              builder: (context, child) {
                final tween = Tween<Offset>(
                  begin: Offset(0, 90),
                  end: Offset(0, 30),
                );
                return Transform.translate(
                  offset: tween.evaluate(controller),
                  child: child,
                );
              },
              child: Text(
                'New Recording',
                style: TextStyle(
                  color: VoiceMemosColors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Builder(
                  builder: (context) {
                    final stream = context.select(
                      (RecorderBloc bloc) => bloc.state.recordingStream,
                    );
                    return Waveform(stream: stream);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
