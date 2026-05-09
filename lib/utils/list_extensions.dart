extension ListX<T> on List<T> {
  T removeWhereAndReturn(bool Function(T item) test) {
    final index = indexWhere(test);

    return removeAt(index);
  }
}
