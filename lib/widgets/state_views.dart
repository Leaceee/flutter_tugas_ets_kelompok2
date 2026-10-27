import 'package:flutter/material.dart';

import '../utils/app_theme.dart';

/// Tampilan saat data sedang dimuat.
class LoadingView extends StatelessWidget {
  const LoadingView({super.key, this.message = 'Memuat data...'});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: AppColors.orange),
          const SizedBox(height: 14),
          Text(message, style: const TextStyle(color: AppColors.muted)),
        ],
      ),
    );
  }
}

class _StateBody extends StatelessWidget {
  const _StateBody({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: iconBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: iconColor),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.muted, fontSize: 13),
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 16),
              FilledButton(
                onPressed: onAction,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.orange,
                  minimumSize: const Size(140, 46),
                ),
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Tampilan saat tidak ada data.
class EmptyView extends StatelessWidget {
  const EmptyView({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return _StateBody(
      icon: icon,
      iconColor: AppColors.orangeDark,
      iconBackground: AppColors.peach,
      title: title,
      subtitle: subtitle,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }
}

/// Tampilan saat terjadi error, lengkap dengan tombol coba lagi.
class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return _StateBody(
      icon: Icons.error_outline_rounded,
      iconColor: AppColors.red,
      iconBackground: AppColors.redSoft,
      title: 'Terjadi masalah',
      subtitle: message,
      actionLabel: 'Coba lagi',
      onAction: onRetry,
    );
  }
}
