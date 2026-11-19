import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/models/enums.dart';
import '../../../../core/models/money.dart';
import '../../../../core/network/error_messages.dart';
import '../../../../core/widgets/async_view.dart';
import '../../../../core/widgets/dialogs.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../shared/labels.dart';
import '../data/gym_admin_repository.dart';
import 'admin_providers.dart';

/// Monthly price per tier [R-11].
class PricingScreen extends ConsumerWidget {
  const PricingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.morePricing)),
      body: AsyncView(
        value: ref.watch(tierPricesProvider),
        onRetry: () => ref.invalidate(tierPricesProvider),
        data: (prices) => _PricingForm(prices: prices),
      ),
    );
  }
}

class _PricingForm extends ConsumerStatefulWidget {
  const _PricingForm({required this.prices});

  final List<TierPrice> prices;

  @override
  ConsumerState<_PricingForm> createState() => _PricingFormState();
}

class _PricingFormState extends ConsumerState<_PricingForm> {
  final _form = GlobalKey<FormState>();
  late final _fields = {
    for (final p in widget.prices)
      p.tier: TextEditingController(text: Money.toInput(p.monthlyCents)),
  };
  bool _saving = false;

  @override
  void dispose() {
    for (final c in _fields.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await ref.read(gymAdminRepositoryProvider).updatePrices({
        for (final MapEntry(:key, :value) in _fields.entries)
          key: Money.parseInput(value.text)!,
      });
      ref.invalidate(tierPricesProvider);
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
    return Form(
      key: _form,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.pricingInfo),
          const SizedBox(height: 16),
          for (final tier in Tier.values)
            if (_fields[tier] != null) ...[
              TextFormField(
                key: Key('pricing.${tier.name}'),
                controller: _fields[tier],
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: l10n.pricingMonthly(l10n.tierLabel(tier)),
                ),
                validator: (v) => Money.parseInput(v ?? '') == null
                    ? l10n.validationAmountInvalid
                    : null,
              ),
              const SizedBox(height: 16),
            ],
          FilledButton(
            key: const Key('pricing.save'),
            onPressed: _saving ? null : _save,
            child: Text(l10n.commonSave),
          ),
        ],
      ),
    );
  }
}
