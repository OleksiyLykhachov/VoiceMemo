import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

import 'package:voice_memos/presentation/presentation.dart';

import '../record_button/record_button.dart';
import 'record_panel_shape_painter.dart';
import 'recording_duration.dart';

class RecordPanel extends StatelessWidget {
  static const defaultMinHeight = 170.0;
  static const defaultPadding = EdgeInsets.all(20);
  static const defaultButtonGap = 24.0;

  final double minHeight;
  final EdgeInsets padding;
  final double buttonGap;
  final Color backgroundColor;

  const RecordPanel({
    this.minHeight = defaultMinHeight,
    this.padding = defaultPadding,
    this.buttonGap = defaultButtonGap,
    this.backgroundColor = VoiceMemosColors.black,
    super.key,
  }) : assert(minHeight >= 0),
       assert(buttonGap >= 0);

  @override
  Widget build(BuildContext context) {
    final resolvedPadding = padding.resolve(Directionality.of(context));

    return SizedBox(
      width: double.infinity,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: minHeight),

        child: CustomPaint(
          painter: RecordPanelShapePainter(
            color: backgroundColor,
            buttonCenterY: resolvedPadding.top + RecordButton.size / 2,
            buttonRadius: RecordButton.size / 2,
          ),

          child: Padding(
            padding: padding,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const _RecordPanelButton(),
                Gap(buttonGap),
                const _RecordPanelStatus(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RecordPanelButton extends StatelessWidget {
  const _RecordPanelButton();

  @override
  Widget build(BuildContext context) {
    final recording = context.select(
      (RecorderBloc bloc) => bloc.state.recording,
    );

    return RecordButton(
      recording: recording,
      onTap: () {
        HapticFeedback.mediumImpact();

        final bloc = context.read<RecorderBloc>();
        if (bloc.state.recording) {
          bloc.add(RecorderEvent.stop());
        } else {
          bloc.add(RecorderEvent.start());
        }
      },
    );
  }
}

class _RecordPanelStatus extends StatelessWidget {
  const _RecordPanelStatus();

  @override
  Widget build(BuildContext context) {
    final recording = context.select(
      (RecorderBloc bloc) => bloc.state.recording,
    );

    return AnimatedSwitcher(
      duration: Durations.long2,
      child: recording ? const _RecordingTimer() : const _IdleHint(),
    );
  }
}

class _RecordingTimer extends StatelessWidget {
  const _RecordingTimer();

  @override
  Widget build(BuildContext context) {
    final startedAt = context.select(
      (RecorderBloc bloc) => bloc.state.startedAt,
    );

    if (startedAt == null) {
      return const SizedBox.shrink();
    }

    return RecordingDuration(startedAt);
  }
}

class _IdleHint extends StatelessWidget {
  const _IdleHint();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Tap to record a new memo',
      style: VoiceMemosTextStyles.bodySmall.copyWith(
        color: VoiceMemosColors.textSecondary,
      ),
    );
  }
}
