import 'package:material_ui/material_ui.dart';

import '../../l10n/generated/app_localizations.dart';
import '../utils/phone.dart';
import '../utils/validators.dart';

/// Phone input with a country-code prefix selector [R-40]. Validates with the
/// backend rules; read the value with [normalizePhone] and [countryCode].
class PhoneField extends StatelessWidget {
  const PhoneField({
    super.key,
    required this.controller,
    required this.countryCode,
    required this.onCountryCodeChanged,
    this.label,
    this.textInputAction = TextInputAction.next,
    this.autofill = false,
  });

  final TextEditingController controller;
  final String countryCode;
  final ValueChanged<String> onCountryCodeChanged;
  final String? label;
  final TextInputAction textInputAction;
  final bool autofill;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final codes = countryCodes.contains(countryCode)
        ? countryCodes
        : [countryCode, ...countryCodes];
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.phone,
      textInputAction: textInputAction,
      autofillHints: autofill ? const [AutofillHints.telephoneNumber] : null,
      decoration: InputDecoration(
        labelText: label ?? l10n.loginPhoneLabel,
        hintText: l10n.loginPhoneHint,
        prefixIcon: Semantics(
          label: l10n.loginCountryCodeLabel,
          child: Padding(
            padding: const EdgeInsetsDirectional.only(start: 12, end: 4),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: countryCode,
                items: [
                  for (final code in codes)
                    DropdownMenuItem(value: code, child: Text(code)),
                ],
                onChanged: (code) {
                  if (code != null) onCountryCodeChanged(code);
                },
              ),
            ),
          ),
        ),
      ),
      validator: (v) => Validators(l10n).phone(v, countryCode: countryCode),
    );
  }
}
