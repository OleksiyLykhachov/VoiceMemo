import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voice_memos/presentation/home/bloc/bloc.dart';
import 'package:voice_memos/utils/utils.dart';

import '../dialogs/save_record/save_record.dart';
import 'widgets/home_content.dart';
import 'widgets/recorder_overlay/recorder_overlay.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> _onNewRecord(
    BuildContext context,
    File file,
    Duration duration,
  ) async {
    final bloc = context.read<RecordsBloc>();

    await Future.delayed(const Duration(milliseconds: 550));

    if (!context.mounted) {
      return;
    }

    final name = await SaveRecordBottomSheet.show(
      context: context,
      duration: duration,
    );

    if (name == null) {
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
    return MultiBlocProvider(
      providers: [
        BlocProvider<RecorderBloc>(
          create: (context) {
            return context.getIt();
          },
        ),
        BlocProvider<RecordsBloc>(
          lazy: false,
          create: (context) {
            final bloc = context.getIt<RecordsBloc>();

            bloc.add(const RecordsEvent.load());

            return bloc;
          },
        ),
      ],
      child: BlocNotificationListener<RecorderNotification, RecorderBloc>(
        listen: (context, notificaiton) {
          notificaiton.whenOrNull(
            recorded: (file, duration) {
              _onNewRecord(context, file, duration);
            },
          );
        },
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: RecorderOverlay(
            child: const HomeContent(),
          ),
        ),
      ),
    );
  }
}
