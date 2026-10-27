import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color orange = Color(0xFFFF6B2C);
  static const Color orangeDark = Color(0xFFEA580C);
  static const Color orangeSoft = Color(0xFFFFF1E8);
  static const Color peach = Color(0xFFFFE4D0);
  static const Color cream = Color(0xFFFFF8F2);
  static const Color ink = Color(0xFF1F1B2D);
  static const Color muted = Color(0xFF7A7589);
  static const Color border = Color(0xFFF1E4DA);
  static const Color green = Color(0xFF16A34A);
  static const Color greenSoft = Color(0xFFDCFCE7);
  static const Color amberSoft = Color(0xFFFEF3C7);
  static const Color amberText = Color(0xFF92400E);
  static const Color red = Color(0xFFDC2626);
  static const Color redSoft = Color(0xFFFEE2E2);
  static const Color shadow = Color(0x14000000);
}

/// Dekorasi kartu putih yang dipakai ulang di banyak tempat.
BoxDecoration appCard({Color color = Colors.white, double radius = 20}) {
  return BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(radius),
    boxShadow: const [
      BoxShadow(color: AppColors.shadow, blurRadius: 10, offset: Offset(0, 3)),
    ],
  );
}

ThemeData buildAppTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.orange,
    brightness: Brightness.light,
  );

  OutlineInputBorder border(Color color, [double width = 1.2]) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.cream,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.cream,
      foregroundColor: AppColors.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: border(AppColors.border),
      enabledBorder: border(AppColors.border),
      focusedBorder: border(AppColors.orange, 1.8),
      errorBorder: border(AppColors.red),
      focusedErrorBorder: border(AppColors.red, 1.8),
    ),
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: Colors.white,
      indicatorColor: AppColors.peach,
    ),
  );
}
