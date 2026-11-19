import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/network/error_messages.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/async_view.dart';
import '../../../../core/widgets/dialogs.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../data/gym_admin_repository.dart';
import 'admin_providers.dart';

/// Gym settings. The time zone is read-only (server env, see DECISIONS).
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.moreSettings)),
      body: AsyncView(
        value: ref.watch(gymSettingsProvider),
        onRetry: () => ref.invalidate(gymSettingsProvider),
        data: (s) => _SettingsForm(settings: s),
      ),
    );
  }
}

class _SettingsForm extends ConsumerStatefulWidget {
  const _SettingsForm({required this.settings});

  final GymSettings settings;

  @override
  ConsumerState<_SettingsForm> createState() => _SettingsFormState();
}

class _SettingsFormState extends ConsumerState<_SettingsForm> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.settings.gymName);
  late final _cooldown = TextEditingController(
    text: '${widget.settings.checkinCooldownMinutes}',
  );
  late final _inside = TextEditingController(
    text: '${widget.settings.insideWindowMinutes}',
  );
  late final _country = TextEditingController(
    text: widget.settings.defaultCountryCode,
  );
  bool _saving = false;

  static final _countryCode = RegExp(r'^\+[1-9]\d{0,3}$');

  @override
  void dispose() {
    _name.dispose();
    _cooldown.dispose();
    _inside.dispose();
    _country.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await ref
          .read(gymAdminRepositoryProvider)
          .updateSettings(
            gymName: _name.text.trim(),
            checkinCooldownMinutes: int.parse(_cooldown.text.trim()),
            insideWindowMinutes: int.parse(_inside.text.trim()),
            defaultCountryCode: _country.text.trim(),
          );
      ref.invalidate(gymSettingsProvider);
      if (mounted) showMessage(context, l10n.commonSaved);
    } on Object catch (e) {
      if (mounted) showMessage(context, errorMessage(l10n, e));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final v = Validators(l10n);
    const gap = SizedBox(height: 16);
    return Form(
      key: _form,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextFormField(
            key: const Key('settings.gymName'),
            controller: _name,
            maxLength: 100,
            decoration: InputDecoration(labelText: l10n.settingsGymName),
            validator: v.required,
          ),
          TextFormField(
            key: const Key('settings.cooldown'),
            controller: _cooldown,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: l10n.settingsCooldown),
            validator: (x) => v.intInRange(x, 1, 1440),
          ),
          gap,
          TextFormField(
            key: const Key('settings.inside'),
            controller: _inside,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: l10n.settingsInsideWindow),
            validator: (x) => v.intInRange(x, 1, 1440),
          ),
          gap,
          TextFormField(
            key: const Key('settings.countryCode'),
            controller: _country,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(labelText: l10n.settingsCountryCode),
            validator: (x) => _countryCode.hasMatch(x?.trim() ?? '')
                ? null
                : l10n.validationPhoneInvalid,
          ),
          gap,
          InputDecorator(
            decoration: InputDecoration(
              labelText: l10n.settingsTimezone,
              helperText: l10n.settingsTimezoneHint,
              enabled: false,
            ),
            child: Text(widget.settings.timezone),
          ),
          const SizedBox(height: 24),
          FilledButton(
            key: const Key('settings.save'),
            onPressed: _saving ? null : _save,
            child: Text(l10n.commonSave),
          ),
        ],
      ),
    );
  }
}
