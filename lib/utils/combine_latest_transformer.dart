import 'dart:async';

final class CombineLatestTransformer<T, S, R>
    extends StreamTransformerBase<T, R> {
  CombineLatestTransformer(this._other, this._combiner);

  final Stream<S> _other;
  final R Function(T first, S second) _combiner;

  @override
  Stream<R> bind(Stream<T> stream) {
    late final StreamController<R> controller;
    StreamSubscription<T>? firstSubscription;
    StreamSubscription<S>? secondSubscription;

    var hasFirstValue = false;
    var hasSecondValue = false;
    var isFirstDone = false;
    var isSecondDone = false;

    late T firstValue;
    late S secondValue;

    void emitIfReady() {
      if (hasFirstValue && hasSecondValue) {
        controller.add(_combiner(firstValue, secondValue));
      }
    }

    void closeIfDone() {
      if (isFirstDone && isSecondDone) {
        controller.close();
      }
    }

    controller = StreamController<R>.broadcast(
      sync: true,
      onListen: () {
        firstSubscription = stream.listen(
          (value) {
            firstValue = value;
            hasFirstValue = true;
            emitIfReady();
          },
          onError: controller.addError,
          onDone: () {
            isFirstDone = true;
            closeIfDone();
          },
        );

        secondSubscription = _other.listen(
          (value) {
            secondValue = value;
            hasSecondValue = true;
            emitIfReady();
          },
          onError: controller.addError,
          onDone: () {
            isSecondDone = true;
            closeIfDone();
          },
        );
      },
      onCancel: () async {
        await firstSubscription?.cancel();
        await secondSubscription?.cancel();
      },
    );

    return controller.stream;
  }
}

extension CombineLatestStreamExtension<T> on Stream<T> {
  Stream<R> combineLatestWith<S, R>(
    Stream<S> other,
    R Function(T first, S second) combiner,
  ) {
    return transform(CombineLatestTransformer<T, S, R>(other, combiner));
  }
}
