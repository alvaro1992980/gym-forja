import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/network/error_messages.dart';
import '../../../../core/utils/phone.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/async_view.dart';
import '../../../../core/widgets/chip_bar.dart';
import '../../../../core/widgets/dialogs.dart';
import '../../../../core/widgets/phone_field.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../settings/data/gym_admin_repository.dart';
import '../../settings/presentation/admin_providers.dart';
import '../../shared/labels.dart';
import '../../shared/payment_widgets.dart';
import '../../shared/temporary_password_screen.dart';

/// Staff accounts (admins, trainers, kiosks): list, deactivate/reactivate
/// [R-43]/[R-45] and create.
class StaffListScreen extends ConsumerStatefulWidget {
  const StaffListScreen({super.key});

  @override
  ConsumerState<StaffListScreen> createState() => _StaffListScreenState();
}

class _StaffListScreenState extends ConsumerState<StaffListScreen> {
  StaffRole? _role;
  bool _includeInactive = false;

  StaffListProvider get _provider =>
      staffListProvider(role: _role, includeInactive: _includeInactive);

  Future<void> _setActive(StaffMember s, {required bool active}) async {
    final l10n = AppLocalizations.of(context);
    if (!await confirmDialog(
      context,
      message: active ? l10n.reactivateConfirm : l10n.deactivateConfirm,
      confirmLabel: active ? l10n.actionReactivate : l10n.actionDeactivate,
      destructive: !active,
    )) {
      return;
    }
    try {
      await ref
          .read(gymAdminRepositoryProvider)
          .setStaffActive(s.id, active: active);
      ref.invalidate(staffListProvider);
      if (mounted) {
        showMessage(
          context,
          active ? l10n.memberReactivated : l10n.memberDeactivated,
        );
      }
    } on Object catch (e) {
      if (mounted) showMessage(context, errorMessage(l10n, e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.moreStaff)),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('staff.new'),
        heroTag: null,
        icon: const Icon(Icons.person_add),
        label: Text(l10n.staffNew),
        onPressed: () => context.push('/admin/more/staff/new'),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 56,
            child: ChipBar(
              children: [
                for (final role in [null, ...StaffRole.values])
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(
                        role == null
                            ? l10n.staffAll
                            : l10n.staffRoleLabel(role),
                      ),
                      selected: _role == role,
                      onSelected: (_) => setState(() => _role = role),
                    ),
                  ),
              ],
            ),
          ),
          SwitchListTile(
            title: Text(l10n.staffShowInactive),
            value: _includeInactive,
            onChanged: (v) => setState(() => _includeInactive = v),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.refresh(_provider.future),
              child: AsyncView(
                value: ref.watch(_provider),
                onRetry: () => ref.invalidate(_provider),
                data: (staff) => staff.isEmpty
                    ? ListView(children: [EmptyView(message: l10n.staffEmpty)])
                    : ListView.separated(
                        padding: const EdgeInsets.only(bottom: 96),
                        itemCount: staff.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, i) {
                          final s = staff[i];
                          return ListTile(
                            key: Key('staff.${s.id}'),
                            title: Text(s.fullName),
                            subtitle: Text(
                              [
                                l10n.staffRoleLabel(s.role),
                                s.phone,
                                if (!s.isActive) l10n.memberInactive,
                              ].join(' · '),
                            ),
                            trailing: PopupMenuButton<bool>(
                              onSelected: (active) =>
                                  _setActive(s, active: active),
                              itemBuilder: (_) => [
                                PopupMenuItem(
                                  value: !s.isActive,
                                  child: Text(
                                    s.isActive
                                        ? l10n.actionDeactivate
                                        : l10n.actionReactivate,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// New ADMIN, TRAINER or KIOSK account; shows the temporary password.
class NewStaffScreen extends ConsumerStatefulWidget {
  const NewStaffScreen({super.key});

  @override
  ConsumerState<NewStaffScreen> createState() => _NewStaffScreenState();
}

class _NewStaffScreenState extends ConsumerState<NewStaffScreen> {
  final _form = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  String _countryCode = defaultCountryCode;
  StaffRole _role = StaffRole.trainer;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _phone.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    if (!_form.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final (staff, password) = await ref
          .read(gymAdminRepositoryProvider)
          .createStaff(
            role: _role,
            firstName: _firstName.text.trim(),
            lastName: _lastName.text.trim(),
            phone: normalizePhone(_phone.text, countryCode: _countryCode)!,
            email: textOrNull(_email),
          );
      ref.invalidate(staffListProvider);
      if (!mounted) return;
      context.pushReplacement(
        '/admin/temporary-password',
        extra: TemporaryPasswordArgs(
          firstName: staff.firstName,
          fullName: staff.fullName,
          phone: staff.phone,
          password: password,
          doneLocation: '/admin/more/staff',
        ),
      );
    } on Object catch (e) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = errorMessage(l10n, e);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final v = Validators(l10n);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.newStaffTitle)),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(l10n.fieldRole),
            const SizedBox(height: 8),
            SegmentedButton<StaffRole>(
              segments: [
                for (final r in StaffRole.values)
                  ButtonSegment(value: r, label: Text(l10n.staffRoleLabel(r))),
              ],
              selected: {_role},
              onSelectionChanged: (s) => setState(() => _role = s.first),
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: const Key('staff.firstName'),
              controller: _firstName,
              textCapitalization: TextCapitalization.words,
              maxLength: 80,
              decoration: InputDecoration(labelText: l10n.profileFirstName),
              validator: v.required,
            ),
            TextFormField(
              key: const Key('staff.lastName'),
              controller: _lastName,
              textCapitalization: TextCapitalization.words,
              maxLength: 80,
              decoration: InputDecoration(labelText: l10n.profileLastName),
              validator: v.required,
            ),
            PhoneField(
              key: const Key('staff.phone'),
              controller: _phone,
              countryCode: _countryCode,
              onCountryCodeChanged: (c) => setState(() => _countryCode = c),
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: const Key('staff.email'),
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(labelText: l10n.profileEmail),
              validator: v.optionalEmail,
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(
                _error!,
                key: const Key('staff.error'),
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 24),
            FilledButton(
              key: const Key('staff.create'),
              onPressed: _saving ? null : _submit,
              child: Text(l10n.staffCreate),
            ),
          ],
        ),
      ),
    );
  }
}
