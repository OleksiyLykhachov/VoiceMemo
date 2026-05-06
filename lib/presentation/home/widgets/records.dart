import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:voice_memos/domain/domain.dart';
import 'package:voice_memos/presentation/presentation.dart';

import 'empty_home_poster.dart';
import 'record_widget/record_widget.dart';
import 'records_stack.dart';

class Records extends StatelessWidget {
  final double cardRadius;

  const Records({
    required this.cardRadius,
    super.key,
  });

  Future<void> _showOptions(BuildContext context, Record record) async {}

  RecordCallbacks? _getCallbacks(
    BuildContext context,
    bool active,
    Record record,
  ) {
    if (!active) {
      return null;
    }

    final bloc = context.read<PlayerBloc>();

    return RecordCallbacks(
      onTogglePlay: () {
        bloc.add(
          PlayerEvent.togglePlay(),
        );
      },
      seekBackward: (value) {
        bloc.add(PlayerEvent.seekBackward(value));
      },
      seekFroward: (value) {
        bloc.add(PlayerEvent.seekForward(value));
      },
      showOptions: () => _showOptions(context, record),
    );
  }

  @override
  Widget build(BuildContext context) {
    final records = context.select((RecordsBloc bloc) {
      return bloc.state.records;
    });

    Widget recordBuilder(
      BuildContext context,
      int index,
      Animation<double> animation, {
      bool active = false,
    }) {
      final record = records[index];

      return Builder(
        builder: (context) {
          final recordState = context.select((
            PlayerBloc bloc,
          ) {
            return bloc.state.getRecordState(record);
          });

          return RecordWidget(
            key: ValueKey(record.id),
            playing: recordState.playing,
            progress: recordState.progress,
            callbacks: _getCallbacks(context, active, record),
            record: record,
            animation: animation,
          );
        },
      );
    }

    if (records.isEmpty) {
      return Center(
        child: EmptyHomePoster(),
      );
    }

    return RecordsStack(
      itemsCount: records.length,
      cardHeight: cardRadius,
      cardOffset: cardRadius * 0.25,
      onRecordChanged: (index) {
        final record = records[index];
        context.read<PlayerBloc>().add(
          PlayerEvent.setRecord(record),
        );
      },
      builder: recordBuilder,
    );
  }
}

typedef RecordState = ({bool playing, double progress});

extension on PlayerState {
  RecordState getRecordState(Record record) {
    if (this.record?.id == record.id) {
      return (playing: playing, progress: progress);
    }

    return (playing: false, progress: 0);
  }
}
