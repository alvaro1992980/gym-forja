import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/models/enums.dart';
import '../../../core/models/money.dart';
import '../../../core/widgets/tier_badge.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../settings/presentation/admin_providers.dart';
import 'labels.dart';

/// Tier picker that shows each tier's monthly price (section 9.3 #3).
class TierSelector extends ConsumerWidget {
  const TierSelector({
    super.key,
    required this.value,
    required this.onChanged,
    this.tiers = Tier.values,
  });

  final Tier? value;
  final ValueChanged<Tier> onChanged;
  final List<Tier> tiers;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final prices = ref.watch(tierPricesProvider).value;
    return RadioGroup<Tier>(
      groupValue: value,
      onChanged: (t) {
        if (t != null) onChanged(t);
      },
      child: Column(
        children: [
          for (final tier in tiers)
            RadioListTile<Tier>(
              key: Key('tier.${tier.name}'),
              value: tier,
              contentPadding: EdgeInsets.zero,
              title: Align(
                alignment: AlignmentDirectional.centerStart,
                child: TierBadge(tier),
              ),
              subtitle: prices == null
                  ? null
                  : Text(
                      l10n.tierWithPrice(
                        Money.format(
                          prices.firstWhere((p) => p.tier == tier).monthlyCents,
                        ),
                      ),
                    ),
            ),
        ],
      ),
    );
  }
}

/// Months picker: 1, 2, 3, 6, 12 or any 1–12 under "Otro" (section 9.3 #3).
class MonthsSelector extends StatelessWidget {
  const MonthsSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  static const quick = [1, 2, 3, 6, 12];

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final custom = !quick.contains(value);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final m in quick)
          ChoiceChip(
            key: Key('months.$m'),
            label: Text('$m'),
            selected: value == m,
            onSelected: (_) => onChanged(m),
          ),
        DropdownButton<int>(
          key: const Key('months.other'),
          hint: Text(l10n.monthsOther),
          value: custom ? value : null,
          items: [
            for (var m = 1; m <= 12; m++)
              DropdownMenuItem(value: m, child: Text(l10n.paymentMonths(m))),
          ],
          onChanged: (m) {
            if (m != null) onChanged(m);
          },
        ),
      ],
    );
  }
}

/// Amount, method and note of a payment. The note is required when the
/// amount differs from [suggestedCents] ([R-10], [R-13]).
class PaymentFields extends StatelessWidget {
  const PaymentFields({
    super.key,
    required this.amount,
    required this.note,
    required this.method,
    required this.onMethodChanged,
    required this.suggestedCents,
    this.requireMethod = true,
  });

  final TextEditingController amount;
  final TextEditingController note;
  final PaymentMethod? method;
  final ValueChanged<PaymentMethod?> onMethodChanged;
  final int? suggestedCents;
  final bool requireMethod;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          key: const Key('payment.amount'),
          controller: amount,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(labelText: l10n.fieldAmount),
          validator: (v) => Money.parseInput(v ?? '') == null
              ? l10n.validationAmountInvalid
              : null,
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<PaymentMethod>(
          key: const Key('payment.method'),
          initialValue: method,
          decoration: InputDecoration(labelText: l10n.fieldMethod),
          items: [
            for (final m in PaymentMethod.values)
              DropdownMenuItem(value: m, child: Text(l10n.methodLabel(m))),
          ],
          onChanged: onMethodChanged,
          validator: (m) =>
              requireMethod && m == null ? l10n.validationRequired : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          key: const Key('payment.note'),
          controller: note,
          maxLength: 500,
          maxLines: 2,
          minLines: 1,
          decoration: InputDecoration(
            labelText: l10n.fieldNote,
            helperText: l10n.noteRequiredHint,
          ),
          validator: (v) {
            final cents = Money.parseInput(amount.text);
            final differs =
                suggestedCents != null &&
                cents != null &&
                cents != suggestedCents;
            return differs && (v == null || v.trim().isEmpty)
                ? l10n.validationNoteRequired
                : null;
          },
        ),
      ],
    );
  }
}

/// Keeps an amount field in sync with the server suggestion until the admin
/// edits it.
class SuggestedAmountSync {
  int? _lastSuggested;

  void apply(TextEditingController amount, int suggestedCents) {
    final current = Money.parseInput(amount.text);
    if (amount.text.isEmpty || current == _lastSuggested) {
      amount.text = Money.toInput(suggestedCents);
    }
    _lastSuggested = suggestedCents;
  }
}

/// Trimmed text or null.
String? textOrNull(TextEditingController c) {
  final v = c.text.trim();
  return v.isEmpty ? null : v;
}
