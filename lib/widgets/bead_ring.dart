import 'dart:math' as math;

import 'package:flutter/material.dart';

/// The bead-ring jewellery icon used for the collection: a faint thread
/// circle with 8 beads in the design colour and one gold bead on top.
class BeadRing extends StatelessWidget {
  const BeadRing({super.key, required this.colour, this.size = 30});

  final Color colour;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _BeadRingPainter(colour),
    );
  }
}

class _BeadRingPainter extends CustomPainter {
  _BeadRingPainter(this.colour);
  final Color colour;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 24; // drawn on a 24-unit grid
    final centre = Offset(12 * s, 12 * s);
    canvas.drawCircle(
      centre,
      7.5 * s,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1 * s
        ..color = colour.withAlpha(89), // 35%
    );
    for (var i = 0; i < 8; i++) {
      final a = -math.pi / 2 + i * math.pi / 4;
      final p = centre + Offset(math.cos(a), math.sin(a)) * (7.5 * s);
      canvas.drawCircle(
          p, 2.5 * s, Paint()..color = i == 0 ? const Color(0xFFE2B04A) : colour);
    }
  }

  @override
  bool shouldRepaint(covariant _BeadRingPainter old) => old.colour != colour;
}

/// Rounded tile with a soft tint of the design colour and a bead ring inside.
class BeadTile extends StatelessWidget {
  const BeadTile(
      {super.key, required this.colour, this.size = 42, this.radius = 12});

  final Color colour;
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colour.withAlpha(34),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: BeadRing(colour: colour, size: size * 0.72),
    );
  }
}

/// Simple round bead (used for materials and trend palettes).
class Bead extends StatelessWidget {
  const Bead({super.key, required this.colour, this.size = 16});
  final Color colour;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colour,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0x14121212)),
        boxShadow: const [
          BoxShadow(
              color: Color(0x1F000000), offset: Offset(-1.5, -1.5), blurRadius: 0, spreadRadius: -1),
        ],
      ),
    );
  }
}
