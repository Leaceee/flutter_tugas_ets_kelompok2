import 'package:flutter/material.dart';

import '../utils/app_theme.dart';

/// Pola mirip kode QR yang dibuat dari kode order. Ini hanya tampilan
/// untuk demo, bukan QR sungguhan. Yang dibaca penjual adalah teks kodenya.
class OrderCodeView extends StatelessWidget {
  const OrderCodeView({super.key, required this.code, this.size = 120});

  final String code;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: CustomPaint(painter: _CodePainter(code)),
    );
  }
}

class _CodePainter extends CustomPainter {
  _CodePainter(this.data);

  final String data;
  static const int _n = 21;

  @override
  void paint(Canvas canvas, Size size) {
    final cell = size.width / _n;
    final dark = Paint()..color = AppColors.ink;
    final light = Paint()..color = Colors.white;

    var seed = 7;
    for (final unit in data.codeUnits) {
      seed = (seed * 31 + unit) & 0x7fffffff;
    }

    bool inFinder(int x, int y) =>
        (x < 8 && y < 8) || (x >= _n - 8 && y < 8) || (x < 8 && y >= _n - 8);

    for (var y = 0; y < _n; y++) {
      for (var x = 0; x < _n; x++) {
        if (inFinder(x, y)) continue;
        seed = (seed * 1103515245 + 12345) & 0x7fffffff;
        if ((seed >> 16) % 3 == 0) {
          canvas.drawRect(
            Rect.fromLTWH(x * cell, y * cell, cell + 0.5, cell + 0.5),
            dark,
          );
        }
      }
    }

    void finder(int ox, int oy) {
      canvas.drawRect(
        Rect.fromLTWH(ox * cell, oy * cell, 7 * cell, 7 * cell),
        dark,
      );
      canvas.drawRect(
        Rect.fromLTWH((ox + 1) * cell, (oy + 1) * cell, 5 * cell, 5 * cell),
        light,
      );
      canvas.drawRect(
        Rect.fromLTWH((ox + 2) * cell, (oy + 2) * cell, 3 * cell, 3 * cell),
        dark,
      );
    }

    finder(0, 0);
    finder(_n - 7, 0);
    finder(0, _n - 7);
  }

  @override
  bool shouldRepaint(covariant _CodePainter oldDelegate) =>
      oldDelegate.data != data;
}
