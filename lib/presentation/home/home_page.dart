import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nested/nested.dart';

import 'package:voice_memos/presentation/presentation.dart';
import 'package:voice_memos/utils/utils.dart';

import 'widgets/home_content.dart';
import 'widgets/home_blocs_wrapper.dart';
import 'widgets/recorder_overlay/recorder_overlay.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> _onNewRecord(
    BuildContext context,
    File file,
    Duration duration,
  ) async {
    final bloc = context.read<RecordsBloc>();

    // To finish recorder animation
    await Future.delayed(const Duration(milliseconds: 500));

    if (!context.mounted) {
      return;
    }

    final name = await SaveRecordBottomSheet.show(
      context: context,
      duration: duration,
    );

    if (name == null) {
      await file.delete();
      return;
    }

    bloc.add(
      RecordsEvent.save(
        file: file,
        name: name,
        duration: duration,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return HomeBlocsWrapper(
      child: Nested(
        children: [
          BlocNotificationListener<RecorderNotification, RecorderBloc>(
            listen: (context, notificaiton) {
              notificaiton.whenOrNull(
                recorded: (file, duration) {
                  _onNewRecord(context, file, duration);
                },
                noMicPermission: () {
                  NoMicrophoneAccessDialog.show(context);
                },
                failure: (message) {
                  context.showFailureToast(message);
                },
              );
            },
          ),
          BlocNotificationListener<RecordsNotification, RecordsBloc>(
            listen: (context, notificaiton) {
              notificaiton.whenOrNull(
                failure: (message) {
                  context.showFailureToast(message);
                },
                renamed: (record) {
                  context.showSuccessToast(
                    'Record renamed to "${record.name}"',
                  );
                },
                deleted: (record) {
                  context.showSuccessToast('Deleted "${record.name}"');
                },
              );
            },
          ),

          BlocNotificationListener<PlayerNotification, PlayerBloc>(
            listen: (context, notificaiton) {
              notificaiton.whenOrNull(
                failure: (message) {
                  context.showFailureToast(message);
                },
              );
            },
          ),
        ],
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: VoiceMemosColors.background,
          body: RecorderOverlay(
            child: const HomeContent(),
          ),
        ),
      ),
    );
  }
}
