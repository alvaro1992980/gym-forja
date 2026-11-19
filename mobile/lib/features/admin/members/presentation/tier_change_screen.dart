import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/models/enums.dart';
import '../../../../core/models/money.dart';
import '../../../../core/network/error_messages.dart';
import '../../../../core/widgets/async_view.dart';
import '../../../../core/widgets/dialogs.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../shared/labels.dart';
import '../../shared/payment_widgets.dart';
import '../data/members_repository.dart';
import '../domain/member_models.dart';
import 'members_providers.dart';

/// Tier change during an active period (section 9.3 #6): pick the target
/// tier → upgrade charge [R-13] or downgrade warning [R-14] → confirm.
class TierChangeScreen extends ConsumerWidget {
  const TierChangeScreen({super.key, required this.memberId});

  final String memberId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final detail = ref.watch(memberDetailProvider(memberId));
    return Scaffold(
      appBar: AppBar(title: Text(l10n.tierChangeTitle)),
      body: AsyncView(
        value: detail,
        onRetry: () => ref.invalidate(memberDetailProvider(memberId)),
        data: (m) => _TierChangeForm(member: m),
      ),
    );
  }
}

class _TierChangeForm extends ConsumerStatefulWidget {
  const _TierChangeForm({required this.member});

  final MemberDetail member;

  @override
  ConsumerState<_TierChangeForm> createState() => _TierChangeFormState();
}

class _TierChangeFormState extends ConsumerState<_TierChangeForm> {
  final _form = GlobalKey<FormState>();
  final _amount = TextEditingController();
  final _note = TextEditingController();
  final _sync = SuggestedAmountSync();
  Tier? _toTier;
  PaymentMethod? _method = PaymentMethod.cash;
  bool _submitting = false;
  String? _error;

  Tier get _fromTier => widget.member.membership.tier;

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _submit(TierChangePreview preview) async {
    final l10n = AppLocalizations.of(context);
    if (!_form.currentState!.validate()) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final cents = preview.isUpgrade ? Money.parseInput(_amount.text) : null;
      await ref
          .read(membersRepositoryProvider)
          .changeTier(
            widget.member.id,
            toTier: preview.toTier,
            amountCents: cents,
            method: cents != null && cents > 0 ? _method : null,
            note: textOrNull(_note),
          );
      invalidateMember(ref, widget.member.id);
      if (!mounted) return;
      showMessage(context, l10n.tierChangeDone);
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
    final theme = Theme.of(context);
    final target = _toTier;
    final preview = target == null
        ? null
        : ref.watch(tierChangePreviewProvider(widget.member.id, target));
    if (target != null) {
      ref.listen(tierChangePreviewProvider(widget.member.id, target), (
        _,
        next,
      ) {
        final data = next.value;
        if (data != null && data.isUpgrade) {
          _sync.apply(_amount, Money.centsFromApi(data.suggestedAmount));
        }
      });
    }
    final data = preview?.value;

    return Form(
      key: _form,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.tierChangeCurrent(l10n.tierLabel(_fromTier))),
          const SizedBox(height: 16),
          Text(l10n.tierChangeTarget),
          TierSelector(
            value: _toTier,
            tiers: [
              for (final t in Tier.values)
                if (t != _fromTier) t,
            ],
            onChanged: (t) => setState(() => _toTier = t),
          ),
          if (preview != null) ...[
            const SizedBox(height: 16),
            AsyncView(
              value: preview,
              onRetry: () => ref.invalidate(
                tierChangePreviewProvider(widget.member.id, target!),
              ),
              data: (p) => p.isUpgrade
                  ? Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          l10n.tierChangeUpgradeInfo(
                            p.daysLeft,
                            Money.formatApi(
                              p.suggestedAmount,
                              currency: p.currency,
                            ),
                          ),
                          key: const Key('tierChange.upgradeInfo'),
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                    )
                  : Card(
                      color: theme.colorScheme.errorContainer,
                      child: ListTile(
                        key: const Key('tierChange.downgradeWarning'),
                        leading: Icon(
                          Icons.warning_amber,
                          color: theme.colorScheme.onErrorContainer,
                        ),
                        title: Text(
                          l10n.tierChangeDowngradeWarning,
                          style: TextStyle(
                            color: theme.colorScheme.onErrorContainer,
                          ),
                        ),
                        subtitle: p.fromTier == Tier.premium
                            ? Text(
                                l10n.tierChangePremiumWarning,
                                style: TextStyle(
                                  color: theme.colorScheme.onErrorContainer,
                                ),
                              )
                            : null,
                      ),
                    ),
            ),
          ],
          if (data != null && data.isUpgrade) ...[
            const SizedBox(height: 16),
            PaymentFields(
              amount: _amount,
              note: _note,
              method: _method,
              onMethodChanged: (m) => setState(() => _method = m),
              suggestedCents: Money.centsFromApi(data.suggestedAmount),
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(
              _error!,
              key: const Key('tierChange.error'),
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ],
          const SizedBox(height: 16),
          FilledButton(
            key: const Key('tierChange.confirm'),
            onPressed: _submitting || data == null ? null : () => _submit(data),
            child: Text(l10n.tierChangeConfirm),
          ),
        ],
      ),
    );
  }
}
