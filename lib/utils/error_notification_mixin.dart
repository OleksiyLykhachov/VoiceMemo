mixin ErrorNotificationMixin {
  Future<void> handle(
    Future<void> Function() cb, {
    void Function()? onFinally,
    void Function(Object ex)? onFailure,
    String Function(Object ex)? buildMessage,
    String? errorMessage,
  }) async {
    assert(
      errorMessage == null || buildMessage == null,
      'Only one of errorMessage or buildMessage can be provided.',
    );

    try {
      await cb();
    } catch (ex) {
      String getMessage() {
        if (errorMessage != null) {
          return errorMessage;
        }

        return buildMessage?.call(ex) ?? 'Something went wrong';
      }

      onFailure?.call(ex);

      showError(getMessage());

      return;
    } finally {
      onFinally?.call();
    }
  }

  void showError(String error);
}
