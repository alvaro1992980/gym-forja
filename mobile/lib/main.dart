import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'app.dart';

void main() {
  // Failed requests show an error with a Retry button instead of being
  // retried silently by Riverpod.
  runApp(const ProviderScope(retry: noRetry, child: GymApp()));
}

/// Disables Riverpod's automatic retry of failed providers.
Duration? noRetry(int retryCount, Object error) => null;
