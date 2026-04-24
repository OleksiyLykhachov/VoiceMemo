import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

import '../../bloc/bloc.dart';
import 'record_pannel_clipper.dart';
import 'recording_duration.dart';
import '../record_button/record_button.dart';

class RecordPannel extends StatelessWidget {
  const RecordPannel({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: RecordPanelClipper(
        buttonRadius: (RecordButton.size / 2) * 1.35,
      ),
      clipBehavior: Clip.antiAlias,
      child: Container(
        padding: const EdgeInsets.all(20),
        width: double.infinity,
        height: 170,
        color: Colors.black,
        child: Column(
          children: [
            Builder(
              builder: (context) {
                final show = context.select(
                  (RecorderBloc bloc) => bloc.state.show,
                );

                return RecordButton(
                  recording: show,
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
              },
            ),
            const Gap(24),

            Builder(
              builder: (context) {
                final recording = context.select(
                  (RecorderBloc bloc) => bloc.state.recording,
                );

                return AnimatedSwitcher(
                  duration: Durations.long2,
                  child: recording
                      ? Builder(
                          builder: (context) {
                            final startedAt = context.select(
                              (RecorderBloc bloc) => bloc.state.startedAt,
                            );

                            if (startedAt == null) {
                              return const SizedBox.shrink();
                            }

                            return RecordingDuration(startedAt);
                          },
                        )
                      : Text(
                          'Hold to record a new memo',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
