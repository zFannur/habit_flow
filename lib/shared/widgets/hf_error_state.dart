import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/config/tokens.dart';
import '../../core/error/repository_error.dart';
import '../../core/localization/generated/app_localizations.dart';
import 'hf_button.dart';

/// Error-state widget — аналог HFEmptyState для состояний ошибки.
/// Классифицирует [error] через [RepositoryError] и показывает
/// дружелюбное сообщение с кнопкой действия.
///
/// Для ошибок ИИ-лимита передай [isAiContext] = true, чтобы получить
/// кнопку «Поменять модель» вместо «Подождать».
class HFErrorState extends StatelessWidget {
  const HFErrorState({
    super.key,
    required this.error,
    this.onRetry,
    this.onRelogin,
    this.onChangeModel,
    this.isAiContext = false,
    this.padding,
  });

  final Object error;
  final VoidCallback? onRetry;
  final VoidCallback? onRelogin;
  final VoidCallback? onChangeModel;
  final bool isAiContext;
  final EdgeInsets? padding;

  _ErrorKind _classify() {
    final repo = RepositoryError.from(error);
    return switch (repo) {
      RepositoryNetworkError() => _ErrorKind.network,
      RepositoryUnauthorizedError() => _ErrorKind.unauthorized,
      RepositoryConflictError() => _ErrorKind.generic,
      RepositoryUnknownError() => _detectFromMessage(repo.message),
    };
  }

  _ErrorKind _detectFromMessage(String? message) {
    if (message == null) return _ErrorKind.generic;
    final lower = message.toLowerCase();
    if (lower.contains('429') || lower.contains('rate limit') || lower.contains('quota')) {
      return _ErrorKind.aiLimit;
    }
    if (lower.contains('500') || lower.contains('502') || lower.contains('503') || lower.contains('504')) {
      return _ErrorKind.server;
    }
    if (lower.contains('validation') || lower.contains('invalid')) {
      return _ErrorKind.validation;
    }
    return _ErrorKind.generic;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = HFColors.of(context);
    final kind = _classify();

    final (icon, iconColor, title, desc, primaryLabel, primaryAction, secondaryLabel, secondaryAction) =
        switch (kind) {
      _ErrorKind.network => (
          LucideIcons.wifiOff,
          c.textTertiary,
          l.errorNetworkTitle,
          l.errorNetworkDesc,
          l.errorRetry,
          onRetry,
          null,
          null,
        ),
      _ErrorKind.unauthorized => (
          LucideIcons.lock,
          c.warning,
          l.errorUnauthorizedTitle,
          l.errorUnauthorizedDesc,
          l.errorRelogin,
          onRelogin,
          null,
          null,
        ),
      _ErrorKind.aiLimit => (
          LucideIcons.hourglass,
          c.warning,
          l.errorAiLimitTitle,
          l.errorAiLimitDesc,
          isAiContext ? l.errorChangeModel : l.errorWait,
          isAiContext ? onChangeModel : null,
          isAiContext ? l.errorWait : null,
          null,
        ),
      _ErrorKind.server => (
          LucideIcons.alertTriangle,
          c.danger,
          l.errorServerTitle,
          l.errorServerDesc,
          l.errorRetry,
          onRetry,
          null,
          null,
        ),
      _ErrorKind.validation => (
          LucideIcons.pencil,
          c.accent,
          l.errorValidationTitle,
          l.errorValidationDesc,
          null,
          null,
          null,
          null,
        ),
      _ErrorKind.generic => (
          LucideIcons.alertTriangle,
          c.textTertiary,
          l.errorGenericTitle,
          l.errorGenericDesc,
          l.errorRetry,
          onRetry,
          null,
          null,
        ),
    };

    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 28, color: iconColor),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              height: 1.2,
              letterSpacing: -0.01 * 18,
              color: c.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            desc,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 1.6,
              color: c.textSecondary,
            ),
          ),
          if (primaryLabel != null) ...[
            const SizedBox(height: 28),
            HFButton(
              label: primaryLabel,
              onPressed: primaryAction,
              variant: HFButtonVariant.primary,
            ),
          ],
          if (secondaryLabel != null) ...[
            const SizedBox(height: 12),
            HFButton(
              label: secondaryLabel,
              onPressed: secondaryAction,
              variant: HFButtonVariant.ghost,
            ),
          ],
        ],
      ),
    );
  }
}

enum _ErrorKind { network, unauthorized, aiLimit, server, validation, generic }
