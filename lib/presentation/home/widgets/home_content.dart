import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/records_bloc/records_bloc.dart';
import 'home_background.dart';
import 'records_stack.dart';
import 'empty_home_poster.dart';
import 'record_widget/record_widget.dart';

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
            child: Builder(
              builder: (context) {
                final records = context.select((RecordsBloc bloc) {
                  return bloc.state.records;
                });

                if (records.isEmpty) {
                  return Center(
                    child: EmptyHomePoster(),
                  );
                }

                return RecordsStack(
                  itemsCount: records.length,
                  cardHeight: cardRadius,
                  cardOffset: cardRadius * 0.25,
                  builder: (context, index, animation) {
                    return RecordWidget(
                      key: ValueKey(records[index].id),
                      record: records[index],
                      animation: animation,
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
