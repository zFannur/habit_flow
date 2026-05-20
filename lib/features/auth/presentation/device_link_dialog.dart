import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/generated/app_localizations.dart';
import '../domain/device_link_state.dart';
import 'device_link_controller.dart';

class DeviceLinkDialog extends ConsumerStatefulWidget {
  const DeviceLinkDialog({super.key});

  @override
  ConsumerState<DeviceLinkDialog> createState() => _DeviceLinkDialogState();
}

class _DeviceLinkDialogState extends ConsumerState<DeviceLinkDialog> {
  Timer? _countdownTimer;
  Duration _timeLeft = Duration.zero;

  @override
  void initState() {
    super.initState();
    // Start the linking process automatically on mount
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(deviceLinkControllerProvider.notifier).startLink();
    });
  }

  void _startCountdown(DateTime expiresAt) {
    _countdownTimer?.cancel();
    _updateTimeLeft(expiresAt);
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      _updateTimeLeft(expiresAt);
    });
  }

  void _updateTimeLeft(DateTime expiresAt) {
    final now = DateTime.now().toUtc();
    final difference = expiresAt.toUtc().difference(now);
    if (difference.isNegative) {
      _timeLeft = Duration.zero;
      _countdownTimer?.cancel();
    } else {
      _timeLeft = difference;
    }
    setState(() {});
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(deviceLinkControllerProvider);

    // Watch for success state to close dialog after delay
    ref.listen<DeviceLinkState>(deviceLinkControllerProvider, (previous, next) {
      if (next is DeviceLinkSuccess) {
        _countdownTimer?.cancel();
        Future<void>.delayed(const Duration(seconds: 2), () {
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        });
      } else if (next is DeviceLinkWaiting) {
        _startCountdown(next.expiresAt);
      } else if (next is DeviceLinkFailed) {
        _countdownTimer?.cancel();
      }
    });

    final ColorScheme colors = Theme.of(context).colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 8,
      backgroundColor: colors.surface,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.3), width: 1.5),
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Row with Title & Close button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.deviceLinkTitle,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colors.onSurface,
                        ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    color: colors.onSurfaceVariant,
                    onPressed: () {
                      ref.read(deviceLinkControllerProvider.notifier).cancelLink();
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Dynamic content based on DeviceLinkState
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildContent(context, state, l10n, colors),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    DeviceLinkState state,
    AppLocalizations l10n,
    ColorScheme colors,
  ) {
    switch (state) {
      case DeviceLinkIdle():
      case DeviceLinkOpening():
        return const SizedBox(
          height: 160,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );

      case DeviceLinkWaiting(token: final token):
        return Column(
          key: const ValueKey('waiting_state'),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.primaryContainer.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                l10n.deviceLinkInstructions,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colors.onSurface,
                      height: 1.5,
                    ),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Column(
                children: [
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.deviceLinkWaiting,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  if (_timeLeft != Duration.zero) ...[
                    const SizedBox(height: 6),
                    Text(
                      _formatDuration(_timeLeft),
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: colors.error,
                            fontWeight: FontWeight.bold,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                ref.read(deviceLinkControllerProvider.notifier).telegramService.openBotDeepLink(token);
              },
              icon: const Icon(Icons.telegram, size: 22),
              label: Text(l10n.deviceLinkOpenBotBtn),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        );

      case DeviceLinkSuccess():
        return Column(
          key: const ValueKey('success_state'),
          children: [
            const SizedBox(height: 16),
            Icon(Icons.check_circle_outline, size: 64, color: colors.primary),
            const SizedBox(height: 20),
            Text(
              l10n.deviceLinkSuccess,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.onSurface,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
          ],
        );

      case DeviceLinkFailed(reason: final reason):
        String errorMsg;
        switch (reason) {
          case DeviceLinkFailReason.expired:
            errorMsg = l10n.deviceLinkReasonExpired;
          case DeviceLinkFailReason.consumed:
            errorMsg = l10n.deviceLinkReasonConsumed;
          case DeviceLinkFailReason.network:
            errorMsg = l10n.deviceLinkReasonNetwork;
          case DeviceLinkFailReason.rateLimited:
            errorMsg = 'Rate limit exceeded. Please wait a bit.';
          case DeviceLinkFailReason.unknown:
            errorMsg = l10n.deviceLinkReasonUnknown;
        }

        return Column(
          key: const ValueKey('failed_state'),
          children: [
            const SizedBox(height: 16),
            Icon(Icons.error_outline, size: 64, color: colors.error),
            const SizedBox(height: 20),
            Text(
              l10n.deviceLinkFailed(errorMsg),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colors.onSurface,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () {
                ref.read(deviceLinkControllerProvider.notifier).startLink();
              },
              child: Text(l10n.commonRetry),
            ),
          ],
        );
    }
  }
}
