import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import 'widgets/record_background.dart';
import 'package:voice_memos/domain/domain.dart';

import 'widgets/record_title.dart';
import 'widgets/record_duration.dart';
import 'widgets/player_controls.dart';

class RecordWidget extends StatelessWidget {
  final Record record;
  final bool playing;
  final Animation<double>? animation;
  final Duration position;
  final RecordCallbacks? callbacks;

  const RecordWidget({
    required this.record,
    required this.playing,
    this.position = Duration.zero,
    this.callbacks,
    this.animation,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return RecordBackground(
      progress: record.getProgress(position),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            children: [
              Expanded(
                flex: 1,
                child: Align(
                  alignment: Alignment.center,
                  child: AnimatedBuilder(
                    animation: animation!,
                    builder: (context, widget) {
                      return Transform.translate(
                        offset: Tween(
                          begin: Offset(0, constraints.maxHeight * 0.7),
                          end: Offset.zero,
                        ).evaluate(animation!),
                        child: widget,
                      );
                    },

                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                      ),
                      child: RecordTitle(record.name),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: FadeTransition(
                  opacity: animation!,
                  child: Column(
                    children: [
                      Expanded(
                        child: PlayerControls(
                          onTogglePlay: callbacks?.onTogglePlay,
                          onForward: callbacks?.seekForward,
                          onBackward: callbacks?.seekBackward,
                          playing: playing,
                        ),
                      ),
                      const Gap(8),
                      Expanded(
                        child: Column(
                          children: [
                            Expanded(
                              child: Center(
                                child: RecordDuration(
                                  record.duration - position,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: callbacks?.showOptions,
                              icon: Icon(
                                Icons.more_horiz,
                                size: 30,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class RecordCallbacks {
  final VoidCallback onTogglePlay;
  final ValueChanged<Duration> seekBackward;
  final ValueChanged<Duration> seekForward;
  final VoidCallback showOptions;

  const RecordCallbacks({
    required this.onTogglePlay,
    required this.seekBackward,
    required this.seekForward,
    required this.showOptions,
  });
}

extension on Record {
  double getProgress(Duration position) {
    if (durationMs <= 0) {
      return 0;
    }

    final progress = (position.inMilliseconds) / durationMs;

    return progress.clamp(0, 1);
  }
}
