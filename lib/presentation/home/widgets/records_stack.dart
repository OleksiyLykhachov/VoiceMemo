import 'package:flutter/physics.dart';
import 'package:flutter/widgets.dart';

typedef RecordBuilder =
    Widget Function(
      BuildContext context,
      int index,
      Animation<double> animation,
    );

class RecordsStack extends StatefulWidget {
  final int itemsCount;
  final RecordBuilder builder;
  final double cardOffset;

  final int visibleBackCards;
  final double cardTop;
  final double cardHeight;

  final ValueChanged<int>? onRecordChanged;

  const RecordsStack({
    super.key,
    required this.itemsCount,
    required this.builder,
    this.cardOffset = 14.0,
    this.visibleBackCards = 3,
    this.cardTop = 8.0,
    this.cardHeight = 160.0,
    this.onRecordChanged,
  });

  @override
  State<RecordsStack> createState() => _RecordsStackState();
}

class _RecordsStackState extends State<RecordsStack>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  int _page = 0;
  final List<_PointerEvent> _velocityBuffer = [];

  static const SpringDescription _spring = SpringDescription(
    mass: 1.0,
    stiffness: 220.0,
    damping: 26.0,
  );
  static const int _maxSkip = 4;
  static const double _dampingFactor = 0.28;

  static final _curve = CurveTween(curve: Curves.easeOut);

  static final _scaleTween = Tween<double>(
    begin: 1.0,
    end: 0.75,
  ).chain(_curve);

  static final _frontOpacityTween = Tween<double>(
    begin: 1.0,
    end: 0.0,
  ).chain(_curve);

  static final _backOpacityTween = Tween<double>(
    begin: 1.0,
    end: 0.25,
  ).chain(_curve);

  static final _frontTranslateTween = Tween<double>(
    begin: 0.0,
    end: -45.0,
  ).chain(_curve);

  double get _dragScale => widget.cardHeight;
  double get _currentPage => _controller.value.clamp(0.0, _maxPage);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController.unbounded(vsync: this)
      ..addListener(_syncPage);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double get _maxPage => (widget.itemsCount - 1).toDouble();

  void _onDragStart(DragStartDetails d) {
    _controller.stop();
    _velocityBuffer.clear();
    _velocityBuffer.add(_PointerEvent(d.globalPosition.dy, DateTime.now()));
  }

  void _onDragUpdate(DragUpdateDetails d) {
    _velocityBuffer.add(_PointerEvent(d.globalPosition.dy, DateTime.now()));
    final cutoff = DateTime.now().subtract(const Duration(milliseconds: 80));
    _velocityBuffer.removeWhere((e) => e.time.isBefore(cutoff));

    final delta = (d.primaryDelta ?? 0) / _dragScale;
    _setControllerValue((_currentPage - delta).clamp(0.0, _maxPage));
  }

  void _onDragEnd(DragEndDetails _) {
    final velocityPx = _estimateVelocityPxPerSec();
    final velocityPages = -velocityPx / _dragScale;

    final currentPage = _currentPage;
    final projected = currentPage + velocityPages * _dampingFactor;

    final base = currentPage.round();
    final desired = projected.round();
    final skip = (desired - base).clamp(-_maxSkip, _maxSkip);
    int target = (base + skip).clamp(0, _maxPage.toInt());

    if (target == base) {
      final fraction = currentPage - currentPage.floor();
      target = fraction >= 0.5 ? currentPage.ceil() : currentPage.floor();
      target = target.clamp(0, _maxPage.toInt());
    }

    _setControllerValue(currentPage);
    _controller.animateWith(
      SpringSimulation(_spring, currentPage, target.toDouble(), velocityPages),
    );
  }

  void _setControllerValue(double value) {
    _controller.value = value;
  }

  void _syncPage() {
    final nextPage = _currentPage.round();
    if (_page == nextPage) return;

    widget.onRecordChanged?.call(_page);

    setState(() {
      _page = nextPage;
    });
  }

  double _estimateVelocityPxPerSec() {
    if (_velocityBuffer.length < 2) return 0;
    final first = _velocityBuffer.first;
    final last = _velocityBuffer.last;
    final dt = last.time.difference(first.time).inMicroseconds / 1e6;
    return dt == 0 ? 0 : (last.y - first.y) / dt;
  }

  List<Widget> _buildVisibleCards() {
    final cards = <Widget>[];
    final firstVisible = (_page - 1).clamp(0, widget.itemsCount - 1);
    final lastVisible = (_page + widget.visibleBackCards + 1).clamp(
      0,
      widget.itemsCount - 1,
    );

    for (int i = lastVisible; i >= firstVisible; i--) {
      cards.add(_buildItem(i));
    }

    return cards;
  }

  double _scaleForRank(double rank) {
    final progress = rank.abs().clamp(0.0, 1.0);
    return _scaleTween.transform(progress);
  }

  double _opacityForRank(double rank) {
    if (rank < 0) {
      final progress = (-rank).clamp(0.0, 0.5) / 0.5;
      return _frontOpacityTween.transform(progress);
    }

    final progress = (rank - 1).clamp(0.0, 3.0) / 3.0;
    return _backOpacityTween.transform(progress);
  }

  double _translateYForRank(double rank) {
    if (rank >= 0) return 0.0;
    final progress = (-rank).clamp(0.0, 1.0);
    return _frontTranslateTween.transform(progress);
  }

  Animation<double> _animationForItem(int index) {
    return _CardProgressAnimation(parent: _controller.view, index: index);
  }

  Widget _buildItem(int index) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.builder(
        context,
        index,
        _animationForItem(index),
      ),
      builder: (context, child) {
        final rank = index - _currentPage;
        final top = widget.cardTop + rank * widget.cardOffset;
        final scale = _scaleForRank(rank);
        final opacity = _opacityForRank(rank);
        final translateY = _translateYForRank(rank);

        return Positioned(
          left: 0,
          right: 0,
          top: top,
          height: widget.cardHeight,
          child: Transform.translate(
            offset: Offset(0, translateY),
            child: Transform.scale(
              scale: scale,
              alignment: Alignment.bottomCenter,
              child: Opacity(opacity: opacity, child: child),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onVerticalDragStart: _onDragStart,
      onVerticalDragUpdate: _onDragUpdate,
      onVerticalDragEnd: _onDragEnd,
      child: Stack(
        clipBehavior: Clip.none,
        children: _buildVisibleCards(),
      ),
    );
  }
}

class _PointerEvent {
  final double y;
  final DateTime time;
  const _PointerEvent(this.y, this.time);
}

class _CardProgressAnimation extends Animation<double>
    with AnimationWithParentMixin<double> {
  _CardProgressAnimation({required this.parent, required this.index});

  @override
  final Animation<double> parent;

  final int index;

  @override
  double get value {
    final rank = index - parent.value;
    if (rank <= 0) return 1.0;

    final progress = (1.0 - rank.abs()).clamp(0.0, 1.0);
    return Curves.easeOut.transform(progress);
  }
}
