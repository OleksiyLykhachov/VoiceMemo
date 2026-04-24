import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/recorder_bloc/recorder_bloc.dart';
import '../record_pannel/record_pannel.dart';
import 'recorder_background.dart';
import 'recorder_overlay_content.dart';

class RecorderOverlay extends StatefulWidget {
  final Widget child;

  const RecorderOverlay({
    required this.child,
    super.key,
  });

  @override
  State<RecorderOverlay> createState() => _RecorderOverlayState();
}

class _RecorderOverlayState extends State<RecorderOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: 500,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RecorderBloc, RecorderState>(
      listenWhen: (prev, next) {
        return prev.show != next.show;
      },

      listener: (context, state) {
        if (state.show) {
          _controller.forward();
        } else {
          _controller.reverse();
        }
      },
      child: Stack(
        children: [
          Positioned.fill(child: widget.child),
          Positioned(
            bottom: 0,
            child: IgnorePointer(
              ignoring: true,
              child: RecorderBackground(
                controller: _controller,
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              ignoring: true,
              child: RecorderOverlayContent(
                controller: _controller,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: RecordPannel(),
          ),
        ],
      ),
    );
  }
}
