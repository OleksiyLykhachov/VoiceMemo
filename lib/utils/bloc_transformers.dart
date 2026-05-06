import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:stream_transform/stream_transform.dart';

EventTransformer<E> debounceThenSequential<E>(Duration duration) {
  return (events, mapper) {
    return sequential<E>().call(
      events.debounce(duration),
      mapper,
    );
  };
}

EventTransformer<E> debounceRestartable<E>(Duration duration) {
  return (events, mapper) {
    return restartable<E>().call(
      events.debounce(duration),
      mapper,
    );
  };
}
