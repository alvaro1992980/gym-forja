import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/models/enums.dart';
import '../../../../core/models/money.dart';
import '../../../../core/network/error_messages.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/async_view.dart';
import '../../../../core/widgets/dialogs.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../shared/payment_widgets.dart';
import '../data/members_repository.dart';
import '../domain/member_models.dart';
import 'members_providers.dart';
import 'new_member_screen.dart';

/// Renewal (section 9.3 #5): tier and months → preview of the new period and
/// suggested amount → amount, method, note → confirm.
class RenewScreen extends ConsumerWidget {
  const RenewScreen({super.key, required this.memberId});

  final String memberId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final detail = ref.watch(memberDetailProvider(memberId));
    return Scaffold(
      appBar: AppBar(title: Text(l10n.renewTitle)),
      body: AsyncView(
        value: detail,
        onRetry: () => ref.invalidate(memberDetailProvider(memberId)),
        data: (m) => _RenewForm(member: m),
      ),
    );
  }
}

class _RenewForm extends ConsumerStatefulWidget {
  const _RenewForm({required this.member});

  final MemberDetail member;

  @override
  ConsumerState<_RenewForm> createState() => _RenewFormState();
}

class _RenewFormState extends ConsumerState<_RenewForm> {
  final _form = GlobalKey<FormState>();
  final _amount = TextEditingController();
  final _note = TextEditingController();
  final _sync = SuggestedAmountSync();
  late Tier _tier = widget.member.membership.tier;
  int _months = 1;
  PaymentMethod? _method = PaymentMethod.cash;
  bool _applyTierNow = false;
  bool _submitting = false;
  String? _error;

  RenewalPreviewProvider get _preview =>
      renewalPreviewProvider(widget.member.id, tier: _tier, months: _months);

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    final preview = ref.read(_preview).value;
    if (preview == null || !_form.currentState!.validate()) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await ref
          .read(membersRepositoryProvider)
          .renew(
            widget.member.id,
            tier: _tier,
            months: _months,
            amountCents: Money.parseInput(_amount.text)!,
            method: _method!,
            note: textOrNull(_note),
            applyTierNow:
                _applyTierNow && preview.tierApplies == TierApplies.scheduled,
          );
      invalidateMember(ref, widget.member.id);
      if (!mounted) return;
      showMessage(context, l10n.renewDone);
      context.pop();
    } on Object catch (e) {
      if (mounted) {
        setState(() {
          _submitting = false;
          _error = errorMessage(l10n, e);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final preview = ref.watch(_preview);
    ref.listen(_preview, (_, next) {
      final data = next.value;
      if (data != null) {
        _sync.apply(_amount, Money.centsFromApi(data.suggestedAmount));
      }
    });
    final data = preview.value;

    return Form(
      key: _form,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.fieldTier),
          TierSelector(
            value: _tier,
            onChanged: (t) => setState(() => _tier = t),
          ),
          const SizedBox(height: 8),
          Text(l10n.fieldMonths),
          const SizedBox(height: 8),
          MonthsSelector(
            value: _months,
            onChanged: (m) => setState(() => _months = m),
          ),
          const SizedBox(height: 16),
          PreviewCard(
            preview: preview,
            extra: data == null ? null : _tierTiming(l10n, data),
          ),
          const SizedBox(height: 16),
          PaymentFields(
            amount: _amount,
            note: _note,
            method: _method,
            onMethodChanged: (m) => setState(() => _method = m),
            suggestedCents: data == null
                ? null
                : Money.centsFromApi(data.suggestedAmount),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(
              _error!,
              key: const Key('renew.error'),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: 16),
          FilledButton(
            key: const Key('renew.confirm'),
            onPressed: _submitting || data == null ? null : _submit,
            child: Text(l10n.renewConfirm),
          ),
        ],
      ),
    );
  }

  /// [R-09] When a different tier applies.
  Widget? _tierTiming(AppLocalizations l10n, PaymentPreview p) =>
      switch (p.tierApplies) {
        TierApplies.unchanged => null,
        TierApplies.now => Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(l10n.tierAppliesNow),
        ),
        TierApplies.scheduled => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              _applyTierNow
                  ? l10n.tierAppliesNow
                  : l10n.tierAppliesScheduled(formatApiDate(p.periodStart)),
            ),
            SwitchListTile(
              key: const Key('renew.applyTierNow'),
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.applyTierNowLabel),
              value: _applyTierNow,
              onChanged: (v) => setState(() => _applyTierNow = v),
            ),
          ],
        ),
      };
}
