import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

class GetItProvider extends StatelessWidget {
  final GetIt getIt;
  final Widget child;

  const GetItProvider({required this.child, required this.getIt, super.key});

  @override
  Widget build(BuildContext context) {
    return Provider.value(value: getIt, child: child);
  }
}

extension BuildContextGetItExtenstion on BuildContext {
  GetIt get getIt => read<GetIt>();
}
