import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voice_memos/utils/utils.dart';

import '../bloc/bloc.dart';

class HomeBlocsWrapper extends StatelessWidget {
  final Widget child;

  const HomeBlocsWrapper({
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<RecorderBloc>(
          create: (context) {
            return context.getIt();
          },
        ),
        BlocProvider<PlayerBloc>(
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

      child: child,
    );
  }
}
