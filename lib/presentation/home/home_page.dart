import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voice_memos/presentation/home/bloc/bloc.dart';
import 'package:voice_memos/utils/utils.dart';

import '../dialogs/save_record/save_record.dart';
import 'widgets/home_content.dart';
import 'widgets/recorder_overlay/recorder_overlay.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<RecorderBloc>(
          create: (context) {
            return context.getIt();
          },
        ),
      ],
      child: BlocNotificationListener<RecorderNotification, RecorderBloc>(
        listen: (context, notificaiton) {
          notificaiton.whenOrNull(
            recorded: (file, duration) async {
              // TODO: save recording 
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
