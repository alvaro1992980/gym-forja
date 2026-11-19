import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/network/error_messages.dart';
import '../../../../core/utils/clock.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/phone.dart';
import '../../../../core/widgets/async_view.dart';
import '../../../../core/widgets/dialogs.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../shared/payment_widgets.dart';
import '../data/members_repository.dart';
import '../domain/member_models.dart';
import 'member_form_fields.dart';
import 'members_providers.dart';

/// Edits a member's profile (not tier or dates).
class EditMemberScreen extends ConsumerWidget {
  const EditMemberScreen({super.key, required this.memberId});

  final String memberId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.editMemberTitle)),
      body: AsyncView(
        value: ref.watch(memberDetailProvider(memberId)),
        onRetry: () => ref.invalidate(memberDetailProvider(memberId)),
        data: (m) => _EditForm(member: m),
      ),
    );
  }
}

class _EditForm extends ConsumerStatefulWidget {
  const _EditForm({required this.member});

  final MemberDetail member;

  @override
  ConsumerState<_EditForm> createState() => _EditFormState();
}

class _EditFormState extends ConsumerState<_EditForm> {
  final _form = GlobalKey<FormState>();
  final _c = MemberProfileControllers();
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final m = widget.member;
    _c.firstName.text = m.firstName;
    _c.lastName.text = m.lastName;
    // Show the stored number without the code when it uses a known one.
    final code = countryCodes.firstWhere(m.phone.startsWith, orElse: () => '');
    _c.countryCode = code.isEmpty ? defaultCountryCode : code;
    _c.phone.text = code.isEmpty ? m.phone : m.phone.substring(code.length);
    _c.email.text = m.email ?? '';
    _c.emergencyContact.text = m.emergencyContact ?? '';
    _c.medicalNotes.text = m.medicalNotes ?? '';
    _c.birthDate = m.birthDate == null ? null : parseApiDate(m.birthDate!);
    _c.gender = m.gender;
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    if (!_form.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref
          .read(membersRepositoryProvider)
          .update(
            widget.member.id,
            MemberProfileInput(
              firstName: _c.firstName.text.trim(),
              lastName: _c.lastName.text.trim(),
              phone: _c.normalizedPhone!,
              email: textOrNull(_c.email),
              birthDate: _c.birthDate == null ? null : toApiDate(_c.birthDate!),
              gender: _c.gender,
              emergencyContact: textOrNull(_c.emergencyContact),
              medicalNotes: textOrNull(_c.medicalNotes),
            ),
          );
      invalidateMember(ref, widget.member.id);
      if (!mounted) return;
      showMessage(context, l10n.commonSaved);
      context.pop();
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
    return Form(
      key: _form,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          MemberProfileFields(
            c: _c,
            clock: ref.read(clockProvider),
            onChanged: () => setState(() {}),
          ),
          if (_error != null)
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          const SizedBox(height: 16),
          FilledButton(
            key: const Key('editMember.save'),
            onPressed: _saving ? null : _save,
            child: Text(l10n.commonSave),
          ),
        ],
      ),
    );
  }
}
