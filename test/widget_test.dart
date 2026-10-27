import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tugas_ets_kelompok2/utils/app_theme.dart';
import 'package:flutter_tugas_ets_kelompok2/widgets/state_views.dart';

void main() {
  test('tema aplikasi memakai Material 3 dan warna utama oranye', () {
    final theme = buildAppTheme();
    expect(theme.useMaterial3, isTrue);
    expect(AppColors.orange, equals(const Color(0xFFFF6B2C)));
  });

  testWidgets('EmptyView menampilkan judul dan memanggil aksi saat ditekan',
      (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EmptyView(
            icon: Icons.inbox_rounded,
            title: 'Belum ada data',
            actionLabel: 'Coba',
            onAction: () => tapped = true,
          ),
        ),
      ),
    );
    expect(find.text('Belum ada data'), findsOneWidget);
    await tester.tap(find.text('Coba'));
    expect(tapped, isTrue);
  });
}