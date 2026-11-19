import 'package:material_ui/material_ui.dart';

import '../../../../core/utils/clock.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/phone.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/phone_field.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../shared/labels.dart';

/// Controllers of the member profile form (new member step 1 and edit).
class MemberProfileControllers {
  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final phone = TextEditingController();
  final email = TextEditingController();
  final emergencyContact = TextEditingController();
  final medicalNotes = TextEditingController();
  String countryCode = defaultCountryCode;
  DateTime? birthDate;
  String? gender;

  /// The phone as the API expects it, or null when invalid.
  String? get normalizedPhone =>
      normalizePhone(phone.text, countryCode: countryCode);

  void dispose() {
    for (final c in [
      firstName,
      lastName,
      phone,
      email,
      emergencyContact,
      medicalNotes,
    ]) {
      c.dispose();
    }
  }
}

/// Profile fields of a member (section 9.3 #3.1).
class MemberProfileFields extends StatelessWidget {
  const MemberProfileFields({
    super.key,
    required this.c,
    required this.clock,
    required this.onChanged,
  });

  final MemberProfileControllers c;
  final Clock clock;

  /// Called after a picker changes a value, so the parent rebuilds.
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final v = Validators(l10n);
    const gap = SizedBox(height: 16);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          key: const Key('member.firstName'),
          controller: c.firstName,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          maxLength: 80,
          decoration: InputDecoration(labelText: l10n.profileFirstName),
          validator: v.required,
        ),
        TextFormField(
          key: const Key('member.lastName'),
          controller: c.lastName,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          maxLength: 80,
          decoration: InputDecoration(labelText: l10n.profileLastName),
          validator: v.required,
        ),
        PhoneField(
          key: const Key('member.phone'),
          controller: c.phone,
          countryCode: c.countryCode,
          onCountryCodeChanged: (code) {
            c.countryCode = code;
            onChanged();
          },
        ),
        gap,
        TextFormField(
          key: const Key('member.email'),
          controller: c.email,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(labelText: l10n.profileEmail),
          validator: v.optionalEmail,
        ),
        gap,
        _DateField(
          label: l10n.profileBirthDate,
          value: c.birthDate,
          onTap: () async {
            final today = clock.today();
            final picked = await showDatePicker(
              context: context,
              initialDate: c.birthDate ?? DateTime(today.year - 25),
              firstDate: DateTime(1900),
              lastDate: today,
              initialEntryMode: DatePickerEntryMode.input,
            );
            if (picked != null) {
              c.birthDate = picked;
              onChanged();
            }
          },
        ),
        gap,
        DropdownButtonFormField<String>(
          key: const Key('member.gender'),
          initialValue: c.gender,
          decoration: InputDecoration(labelText: l10n.profileGender),
          items: [
            for (final g in {...genderValues, ?c.gender})
              DropdownMenuItem(value: g, child: Text(l10n.genderLabel(g))),
          ],
          onChanged: (g) {
            c.gender = g;
            onChanged();
          },
        ),
        gap,
        TextFormField(
          key: const Key('member.emergencyContact'),
          controller: c.emergencyContact,
          maxLength: 200,
          decoration: InputDecoration(labelText: l10n.profileEmergencyContact),
        ),
        TextFormField(
          key: const Key('member.medicalNotes'),
          controller: c.medicalNotes,
          maxLength: 2000,
          minLines: 1,
          maxLines: 4,
          decoration: InputDecoration(labelText: l10n.profileMedicalNotes),
        ),
      ],
    );
  }
}

/// Read-only field that opens a date picker.
class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final DateTime? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        child: Text(
          value == null
              ? AppLocalizations.of(context).commonNotSet
              : formatDate(value!),
        ),
      ),
    );
  }
}

/// Date field used by forms outside this file.
class DatePickerField extends StatelessWidget {
  const DatePickerField({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
    this.helperText,
  });

  final String label;
  final DateTime value;
  final VoidCallback onTap;
  final String? helperText;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          helperText: helperText,
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        child: Text(formatDate(value)),
      ),
    );
  }
}
