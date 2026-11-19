import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../l10n/generated/app_localizations.dart';
import '../network/error_messages.dart';
import 'state_views.dart';

/// Loading / error-with-Retry / data for an [AsyncValue] (section 9: every
/// screen that loads data has these states).
class AsyncView<T> extends StatelessWidget {
  const AsyncView({
    super.key,
    required this.value,
    required this.data,
    required this.onRetry,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return switch (value) {
      AsyncValue(:final T value, hasValue: true) => data(value),
      AsyncValue(:final Object error, hasError: true) => ErrorView(
        message: errorMessage(l10n, error),
        onRetry: onRetry,
      ),
      _ => const LoadingView(),
    };
  }
}
