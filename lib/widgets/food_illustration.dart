import 'package:flutter/material.dart';

/// Warna latar lembut untuk tiap jenis ilustrasi.
Color artTint(String art) {
  switch (art) {
    case 'plate':
      return const Color(0xFFFFE4D0);
    case 'tea':
      return const Color(0xFFFFF1C2);
    case 'bowl':
      return const Color(0xFFFFE1DC);
    default:
      return const Color(0xFFF1E3D6);
  }
}

/// Ilustrasi makanan/minuman yang digambar dengan CustomPainter,
/// jadi tidak butuh file gambar tambahan.
class FoodIllustration extends StatelessWidget {
  const FoodIllustration({super.key, required this.art, this.size = 56});

  final String art;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _FoodPainter(art)),
    );
  }
}

class _FoodPainter extends CustomPainter {
  _FoodPainter(this.art);

  final String art;

  Paint _fill(int argb) => Paint()..color = Color(argb);

  Paint _stroke(int argb, double width) => Paint()
    ..color = Color(argb)
    ..style = PaintingStyle.stroke
    ..strokeWidth = width
    ..strokeCap = StrokeCap.round;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 64, size.height / 64);
    switch (art) {
      case 'plate':
        _plate(canvas);
        break;
      case 'bowl':
        _bowl(canvas);
        break;
      case 'tea':
        _tea(canvas);
        break;
      default:
        _coffee(canvas);
    }
    canvas.restore();
  }

  void _plate(Canvas canvas) {
    canvas.drawCircle(const Offset(32, 36), 25, _fill(0xFFFFFFFF));
    canvas.drawCircle(const Offset(32, 36), 19, _fill(0xFFF3F4F6));
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(26, 36), width: 22, height: 18),
      _fill(0xFFFEF3C7),
    );
    canvas.save();
    canvas.translate(41.5, 35.5);
    canvas.rotate(0.35);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: 15, height: 21),
        const Radius.circular(7),
      ),
      _fill(0xFFC2410C),
    );
    canvas.restore();
    canvas.drawCircle(const Offset(22, 49), 3, _fill(0xFFDC2626));
    canvas.drawCircle(const Offset(31, 51), 3.2, _fill(0xFF84CC16));
  }

  void _bowl(Canvas canvas) {
    final bowl = Path()
      ..moveTo(8, 32)
      ..lineTo(56, 32)
      ..arcToPoint(
        const Offset(8, 32),
        radius: const Radius.circular(24),
        clockwise: true,
      )
      ..close();
    canvas.drawPath(bowl, _fill(0xFFDC2626));

    final noodles = Path()..moveTo(14, 30);
    for (var i = 0; i < 4; i++) {
      final x = 14.0 + i * 10;
      noodles.quadraticBezierTo(x + 5, i.isEven ? 20 : 40, x + 10, 30);
    }
    canvas.drawPath(noodles, _stroke(0xFFFBBF24, 4));

    canvas.drawCircle(const Offset(40, 24), 8, _fill(0xFFFFFFFF));
    canvas.drawCircle(const Offset(40, 24), 3.4, _fill(0xFFF59E0B));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(14.5, 14, 3, 10),
        const Radius.circular(1.5),
      ),
      _fill(0xFF22C55E),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(20.5, 12, 3, 11),
        const Radius.circular(1.5),
      ),
      _fill(0xFF16A34A),
    );
  }

  void _tea(Canvas canvas) {
    final cup = Path()
      ..moveTo(20, 20)
      ..lineTo(44, 20)
      ..lineTo(41, 58)
      ..lineTo(23, 58)
      ..close();
    canvas.drawPath(cup, _fill(0xFFF59E0B));
    final ice = _fill(0xB3FFFFFF);
    for (final r in const [
      Rect.fromLTWH(24, 28, 8, 8),
      Rect.fromLTWH(33, 34, 8, 8),
      Rect.fromLTWH(25, 44, 8, 8),
    ]) {
      canvas.drawRRect(RRect.fromRectAndRadius(r, const Radius.circular(2)), ice);
    }
    canvas.drawCircle(const Offset(47, 21), 8, _fill(0xFFFDE047));
    canvas.save();
    canvas.translate(38, 16);
    canvas.rotate(0.2);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: 4, height: 24),
        const Radius.circular(2),
      ),
      _fill(0xFFDC2626),
    );
    canvas.restore();
  }

  void _coffee(Canvas canvas) {
    final cup = Path()
      ..moveTo(14, 26)
      ..lineTo(46, 26)
      ..lineTo(46, 40)
      ..arcToPoint(
        const Offset(14, 40),
        radius: const Radius.circular(16),
        clockwise: true,
      )
      ..close();
    canvas.drawPath(cup, _fill(0xFF78350F));
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(30, 26), width: 32, height: 9),
      _fill(0xFFFDE68A),
    );
    final handle = Path()
      ..moveTo(46, 31)
      ..lineTo(50, 31)
      ..arcToPoint(
        const Offset(50, 45),
        radius: const Radius.circular(7),
        clockwise: true,
      )
      ..lineTo(45, 45);
    canvas.drawPath(handle, _stroke(0xFF78350F, 3.4));
    final steam = _stroke(0xFFCBD5E1, 2.4);
    canvas.drawPath(
      Path()
        ..moveTo(24, 16)
        ..quadraticBezierTo(21, 12, 24, 8),
      steam,
    );
    canvas.drawPath(
      Path()
        ..moveTo(33, 16)
        ..quadraticBezierTo(30, 12, 33, 8),
      steam,
    );
  }

  @override
  bool shouldRepaint(covariant _FoodPainter oldDelegate) =>
      oldDelegate.art != art;
}
