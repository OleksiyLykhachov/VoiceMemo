import 'package:flutter/widgets.dart';

import '../../../presentation.dart';

class RecorderBackground extends StatelessWidget {
  final Animation<double> animation;

  const RecorderBackground({
    required this.animation,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final offset = size.height * 0.05;
    final bgSize = Size(
      size.width,
      size.height + offset,
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final yOffset = Tween(
          begin: bgSize.height,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeInOut)).evaluate(animation);

        return Transform.translate(
          offset: Offset(0, yOffset),
          child: child!,
        );
      },

      child: ClipPath(
        clipper: RecorderBackgroundClipper(
          offset: offset,
        ),
        child: Container(
          height: bgSize.height,
          width: bgSize.width,
          decoration: BoxDecoration(
            color: VoiceMemosColors.black,
          ),
        ),
      ),
    );
  }
}

class RecorderBackgroundClipper extends CustomClipper<Path> {
  final double offset;

  const RecorderBackgroundClipper({
    required this.offset,
    super.reclip,
  });

  @override
  Path getClip(Size size) {
    final Path path = Path();

    final offset = size.height * 0.05;

    path.moveTo(0, offset);
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, offset);
    path.quadraticBezierTo(
      size.width / 2,
      0,
      0,
      offset,
    );

    return path;
  }

  @override
  bool shouldReclip(RecorderBackgroundClipper oldClipper) {
    return oldClipper.offset != offset;
  }
}
