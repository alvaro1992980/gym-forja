import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/auth/session_controller.dart';
import '../../../core/network/error_messages.dart';
import '../../../core/utils/validators.dart';
import '../../../l10n/generated/app_localizations.dart';

/// Forced password change after the first login (section 9.1 #3). On
/// success the session reloads `/me` and the router opens the role home.
class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _new = TextEditingController();
  final _confirm = TextEditingController();
  bool _obscure = true;
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _new.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _current.dispose();
    _new.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting || !_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await ref
          .read(sessionControllerProvider.notifier)
          .changePassword(
            currentPassword: _current.text,
            newPassword: _new.text,
          );
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.changePasswordSuccess)),
      );
    } on Object catch (e) {
      if (mounted) setState(() => _error = errorMessage(l10n, e));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final validators = Validators(l10n);
    final theme = Theme.of(context);

    InputDecoration decoration(String label) => InputDecoration(
      labelText: label,
      suffixIcon: IconButton(
        tooltip: _obscure ? l10n.loginShowPassword : l10n.loginHidePassword,
        icon: Icon(
          _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        ),
        onPressed: () => setState(() => _obscure = !_obscure),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.changePasswordTitle),
        actions: [
          IconButton(
            tooltip: l10n.logout,
            icon: const Icon(Icons.logout),
            onPressed: () =>
                ref.read(sessionControllerProvider.notifier).signOut(),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.changePasswordForcedInfo,
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                TextFormField(
                  key: const Key('changePassword.current'),
                  controller: _current,
                  obscureText: _obscure,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.password],
                  decoration: decoration(l10n.changePasswordCurrentLabel),
                  validator: validators.password,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  key: const Key('changePassword.new'),
                  controller: _new,
                  obscureText: _obscure,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.newPassword],
                  decoration: decoration(l10n.changePasswordNewLabel),
                  validator: (v) =>
                      validators.newPassword(v, current: _current.text),
                ),
                const SizedBox(height: 8),
                _StrengthHint(password: _new.text),
                const SizedBox(height: 16),
                TextFormField(
                  key: const Key('changePassword.confirm'),
                  controller: _confirm,
                  obscureText: _obscure,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  decoration: decoration(l10n.changePasswordConfirmLabel),
                  validator: (v) => validators.confirmPassword(v, _new.text),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _error!,
                    key: const Key('changePassword.error'),
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ],
                const SizedBox(height: 24),
                FilledButton(
                  key: const Key('changePassword.submit'),
                  onPressed: _submitting ? null : _submit,
                  child: _submitting
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.changePasswordSubmit),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StrengthHint extends StatelessWidget {
  const _StrengthHint({required this.password});

  final String password;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    if (password.isEmpty) {
      return Text(
        l10n.passwordStrengthHint,
        style: Theme.of(context).textTheme.bodySmall,
      );
    }
    final strength = passwordStrength(password);
    final (label, value, color) = switch (strength) {
      PasswordStrength.weak => (l10n.passwordStrengthWeak, 1 / 3, scheme.error),
      PasswordStrength.medium => (
        l10n.passwordStrengthMedium,
        2 / 3,
        Colors.orange.shade700,
      ),
      PasswordStrength.strong => (
        l10n.passwordStrengthStrong,
        1.0,
        Colors.green.shade700,
      ),
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(value: value, color: color),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
