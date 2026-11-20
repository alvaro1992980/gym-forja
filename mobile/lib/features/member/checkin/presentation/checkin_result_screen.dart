import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/network/error_messages.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/tier_badge.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../home/presentation/member_home_screen.dart';
import '../domain/checkin_result.dart';

/// Check-in result (section 9.5 #3): success, duplicate, expired membership,
/// invalid QR, inactive account or a failed request.
class CheckinResultScreen extends StatelessWidget {
  const CheckinResultScreen({super.key, required this.outcome});

  final CheckinOutcome outcome;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    void home() => context.go('/member');
    void scanAgain() => context.pushReplacement(MemberRoutes.scan);

    final body = switch (outcome) {
      CheckinAccepted(:final response) => _Result(
        key: const Key('result.accepted'),
        icon: Icons.check_circle,
        color: Colors.green.shade700,
        animate: true,
        title: l10n.checkinWelcome(response.member.firstName),
        details: [
          if (response.duplicate)
            Text(
              l10n.checkinDuplicate(formatTime(response.checkedInAt)),
              key: const Key('result.duplicate'),
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
          const SizedBox(height: 12),
          TierBadge(response.membership.tier),
          const SizedBox(height: 12),
          Text(
            l10n.membershipDaysLeft(response.membership.daysLeft),
            style: theme.textTheme.titleLarge,
          ),
          Text(
            l10n.membershipEndDate(formatApiDate(response.membership.endDate)),
          ),
          const SizedBox(height: 24),
          // Today's workout for PLUS/PREMIUM comes with D12.
          Text(l10n.checkinEnjoy, style: theme.textTheme.titleMedium),
        ],
        action: l10n.checkinGoHome,
        onAction: home,
      ),
      CheckinExpired(:final endDate) => _Result(
        key: const Key('result.expired'),
        icon: Icons.block,
        color: theme.colorScheme.onError,
        background: theme.colorScheme.error,
        title: l10n.checkinExpiredTitle,
        details: [
          if (endDate != null)
            Text(
              l10n.memberExpiredOn(formatApiDate(endDate)),
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onError,
              ),
            ),
          const SizedBox(height: 12),
          Text(
            l10n.checkinExpiredBody,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onError,
            ),
          ),
        ],
        action: l10n.checkinGoHome,
        onAction: home,
      ),
      CheckinInvalidQr() => _Result(
        key: const Key('result.invalidQr'),
        icon: Icons.qr_code_2,
        color: Colors.orange.shade800,
        title: l10n.checkinInvalidQr,
        action: l10n.checkinScanAgain,
        onAction: scanAgain,
        secondary: l10n.checkinGoHome,
        onSecondary: home,
      ),
      CheckinInactive() => _Result(
        key: const Key('result.inactive'),
        icon: Icons.person_off,
        color: theme.colorScheme.error,
        title: l10n.checkinInactive,
        action: l10n.checkinGoHome,
        onAction: home,
      ),
      CheckinFailed(:final error) => _Result(
        key: const Key('result.failed'),
        icon: Icons.cloud_off,
        color: theme.colorScheme.error,
        title: errorMessage(l10n, error),
        action: l10n.checkinScanAgain,
        onAction: scanAgain,
        secondary: l10n.checkinGoHome,
        onSecondary: home,
      ),
    };
    return body;
  }
}

class _Result extends StatelessWidget {
  const _Result({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.action,
    required this.onAction,
    this.background,
    this.details = const [],
    this.animate = false,
    this.secondary,
    this.onSecondary,
  });

  final IconData icon;
  final Color color;
  final Color? background;
  final String title;
  final List<Widget> details;
  final bool animate;
  final String action;
  final VoidCallback onAction;
  final String? secondary;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconWidget = Icon(icon, size: 120, color: color);
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                if (animate)
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.3, end: 1),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.elasticOut,
                    builder: (_, scale, child) =>
                        Transform.scale(scale: scale, child: child),
                    child: iconWidget,
                  )
                else
                  iconWidget,
                const SizedBox(height: 24),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: background != null ? color : null,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ...details,
                const SizedBox(height: 32),
                FilledButton(
                  key: const Key('result.action'),
                  style: background == null
                      ? null
                      : FilledButton.styleFrom(
                          backgroundColor: color,
                          foregroundColor: background,
                        ),
                  onPressed: onAction,
                  child: Text(action),
                ),
                if (secondary != null)
                  TextButton(onPressed: onSecondary, child: Text(secondary!)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
