import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/models/enums.dart';
import '../../../../core/models/money.dart';
import '../../../../core/network/error_messages.dart';
import '../../../../core/utils/device_actions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/async_view.dart';
import '../../../../core/widgets/dialogs.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../core/widgets/tier_badge.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../shared/labels.dart';
import '../../shared/member_status_label.dart';
import '../../shared/temporary_password_screen.dart';
import '../data/members_repository.dart';
import '../domain/member_models.dart';
import 'members_providers.dart';

/// Member detail (section 9.3 #4). The Entrenamiento and Entrenador tabs
/// come with D11/D13.
class MemberDetailScreen extends ConsumerWidget {
  const MemberDetailScreen({super.key, required this.memberId});

  final String memberId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final detail = ref.watch(memberDetailProvider(memberId));
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(detail.value?.fullName ?? ''),
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: l10n.memberTabMembership),
              Tab(text: l10n.memberTabPayments),
              Tab(text: l10n.memberTabCheckins),
              Tab(text: l10n.memberTabProfile),
            ],
          ),
        ),
        body: AsyncView(
          value: detail,
          onRetry: () => ref.invalidate(memberDetailProvider(memberId)),
          data: (m) => RefreshIndicator(
            onRefresh: () => ref.refresh(memberDetailProvider(memberId).future),
            child: TabBarView(
              children: [
                _MembershipTab(member: m),
                _PaymentsTab(member: m),
                _CheckinsTab(member: m),
                _ProfileTab(member: m),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Name, phone actions, tier, status and the days-left ring.
class _Header extends ConsumerWidget {
  const _Header({required this.member});

  final MemberDetail member;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final ms = member.membership;
    final status = !member.isActive
        ? MemberStatus.inactive
        : ms.status == MembershipStatus.expired
        ? MemberStatus.expired
        : MemberStatus.active;
    final actions = ref.read(deviceActionsProvider);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          SizedBox.square(
            dimension: 72,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox.expand(
                  child: CircularProgressIndicator(
                    value: (ms.daysLeft / 30).clamp(0, 1).toDouble(),
                    strokeWidth: 6,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    color: ms.daysLeft == 0
                        ? theme.colorScheme.error
                        : ms.daysLeft <= 7
                        ? Colors.orange.shade700
                        : Colors.green.shade600,
                  ),
                ),
                Text('${ms.daysLeft}', style: theme.textTheme.titleLarge),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    TierBadge(ms.tier),
                    const SizedBox(width: 8),
                    Flexible(
                      child: MemberStatusLabel(
                        status: status,
                        daysLeft: ms.daysLeft,
                        endDate: ms.endDate,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Flexible(child: Text(member.phone)),
                    IconButton(
                      tooltip: l10n.memberCall,
                      icon: const Icon(Icons.call),
                      onPressed: () => actions.call(member.phone),
                    ),
                    IconButton(
                      tooltip: l10n.memberWhatsApp,
                      icon: const Icon(Icons.chat),
                      onPressed: () => actions.whatsApp(member.phone),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MembershipTab extends StatelessWidget {
  const _MembershipTab({required this.member});

  final MemberDetail member;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ms = member.membership;
    final expired = ms.status == MembershipStatus.expired;
    return ListView(
      children: [
        _Header(member: member),
        const Divider(),
        ListTile(
          title: Text(l10n.membershipStart),
          trailing: Text(formatApiDate(ms.startDate)),
        ),
        ListTile(
          title: Text(l10n.membershipEnd),
          trailing: Text(
            formatApiDate(ms.endDate),
            key: const Key('memberDetail.endDate'),
          ),
        ),
        if (ms.nextTier != null && ms.nextTierStartDate != null)
          ListTile(
            leading: const Icon(Icons.schedule),
            title: Text(
              l10n.membershipNextTier(
                l10n.tierLabel(ms.nextTier!),
                formatApiDate(ms.nextTierStartDate!),
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FilledButton.icon(
                key: const Key('memberDetail.renew'),
                icon: const Icon(Icons.autorenew),
                label: Text(l10n.actionRenew),
                onPressed: () =>
                    context.push('/admin/members/${member.id}/renew'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                key: const Key('memberDetail.changeTier'),
                icon: const Icon(Icons.swap_vert),
                label: Text(l10n.actionChangeTier),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                onPressed: expired
                    ? null
                    : () => context.push(
                        '/admin/members/${member.id}/tier-change',
                      ),
              ),
              if (expired) ...[
                const SizedBox(height: 8),
                Text(
                  l10n.changeTierExpiredHint,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _PaymentsTab extends ConsumerWidget {
  const _PaymentsTab({required this.member});

  final MemberDetail member;

  Future<void> _void(
    BuildContext context,
    WidgetRef ref,
    Payment payment,
  ) async {
    final l10n = AppLocalizations.of(context);
    final reason = await reasonDialog(
      context,
      title: l10n.voidTitle,
      message: l10n.voidInfo,
      label: l10n.voidReasonLabel,
      confirmLabel: l10n.paymentVoid,
    );
    if (reason == null) return;
    try {
      await ref.read(membersRepositoryProvider).voidPayment(payment.id, reason);
      invalidateMember(ref, member.id);
      if (context.mounted) showMessage(context, l10n.voidDone);
    } on Object catch (e) {
      if (context.mounted) showMessage(context, errorMessage(l10n, e));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    if (member.payments.isEmpty) {
      return ListView(children: [EmptyView(message: l10n.paymentsEmpty)]);
    }
    return ListView.separated(
      itemCount: member.payments.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final p = member.payments[i];
        return PaymentTile(
          payment: p,
          onVoid: p.isVoided ? null : () => _void(context, ref, p),
        );
      },
    );
  }
}

/// One payment with kind, period, amount, method and void state.
class PaymentTile extends StatelessWidget {
  const PaymentTile({super.key, required this.payment, this.onVoid});

  final Payment payment;
  final VoidCallback? onVoid;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final p = payment;
    final strike = p.isVoided
        ? const TextStyle(decoration: TextDecoration.lineThrough)
        : null;
    final period = p.periodStart != null && p.periodEnd != null
        ? '${formatApiDate(p.periodStart!)} – ${formatApiDate(p.periodEnd!)}'
        : null;
    return ListTile(
      key: Key('payment.${p.id}'),
      isThreeLine: true,
      title: Row(
        children: [
          Expanded(
            child: Text(
              [
                l10n.paymentKindLabel(p.kind),
                l10n.tierLabel(p.tier),
                // Upgrades have no period (months = 0).
                if (p.months > 0) l10n.paymentMonths(p.months),
              ].join(' · '),
              style: strike,
            ),
          ),
          Text(
            Money.formatApi(p.amount, currency: p.currency),
            style: theme.textTheme.titleSmall?.merge(strike),
          ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (period != null) Text(period, style: strike),
          Text(
            '${l10n.methodLabel(p.method)} · '
            '${l10n.paymentRecordedBy(p.recordedBy.fullName, formatInstant(p.paidAt))}',
          ),
          if (p.note != null) Text(p.note!, style: theme.textTheme.bodySmall),
          if (p.isVoided)
            Text(
              l10n.paymentVoided(p.voidReason ?? ''),
              style: TextStyle(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
      trailing: onVoid == null
          ? null
          : IconButton(
              key: Key('payment.${p.id}.void'),
              tooltip: l10n.paymentVoid,
              icon: const Icon(Icons.block),
              onPressed: onVoid,
            ),
    );
  }
}

class _CheckinsTab extends StatelessWidget {
  const _CheckinsTab({required this.member});

  final MemberDetail member;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (member.recentCheckins.isEmpty) {
      return ListView(
        children: [EmptyView(message: l10n.checkinsEmpty, icon: Icons.login)],
      );
    }
    return ListView(
      children: [
        for (final c in member.recentCheckins)
          ListTile(
            leading: const Icon(Icons.login),
            title: Text(formatInstant(c.createdAt)),
            trailing: TierBadge(c.tier),
          ),
      ],
    );
  }
}

class _ProfileTab extends ConsumerWidget {
  const _ProfileTab({required this.member});

  final MemberDetail member;

  Future<void> _resetPassword(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    if (!await confirmDialog(
      context,
      title: l10n.actionResetPassword,
      message: l10n.resetPasswordConfirm,
    )) {
      return;
    }
    try {
      final password = await ref
          .read(membersRepositoryProvider)
          .resetPassword(member.id);
      invalidateMember(ref, member.id);
      if (!context.mounted) return;
      await context.push(
        '/admin/temporary-password',
        extra: TemporaryPasswordArgs(
          firstName: member.firstName,
          fullName: member.fullName,
          phone: member.phone,
          password: password,
          doneLocation: '/admin/members/${member.id}',
        ),
      );
    } on Object catch (e) {
      if (context.mounted) showMessage(context, errorMessage(l10n, e));
    }
  }

  Future<void> _setActive(
    BuildContext context,
    WidgetRef ref, {
    required bool active,
  }) async {
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
          .read(membersRepositoryProvider)
          .setActive(member.id, active: active);
      invalidateMember(ref, member.id);
      if (context.mounted) {
        showMessage(
          context,
          active ? l10n.memberReactivated : l10n.memberDeactivated,
        );
      }
    } on Object catch (e) {
      if (context.mounted) showMessage(context, errorMessage(l10n, e));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final m = member;
    String or(String? v) => v == null || v.isEmpty ? l10n.commonNotSet : v;
    Widget field(String label, String value) =>
        ListTile(title: Text(label), subtitle: Text(value));
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        field(l10n.profileFirstName, m.fullName),
        field(l10n.profilePhone, m.phone),
        field(l10n.profileEmail, or(m.email)),
        field(
          l10n.profileBirthDate,
          m.birthDate == null ? l10n.commonNotSet : formatApiDate(m.birthDate!),
        ),
        field(
          l10n.profileGender,
          m.gender == null ? l10n.commonNotSet : l10n.genderLabel(m.gender!),
        ),
        field(l10n.profileEmergencyContact, or(m.emergencyContact)),
        field(l10n.profileMedicalNotes, or(m.medicalNotes)),
        const Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              OutlinedButton.icon(
                key: const Key('memberDetail.edit'),
                icon: const Icon(Icons.edit),
                label: Text(l10n.actionEdit),
                onPressed: () => context.push('/admin/members/${m.id}/edit'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                key: const Key('memberDetail.resetPassword'),
                icon: const Icon(Icons.lock_reset),
                label: Text(l10n.actionResetPassword),
                onPressed: () => _resetPassword(context, ref),
              ),
              const SizedBox(height: 8),
              if (m.isActive)
                OutlinedButton.icon(
                  key: const Key('memberDetail.deactivate'),
                  icon: const Icon(Icons.person_off),
                  label: Text(l10n.actionDeactivate),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                  ),
                  onPressed: () => _setActive(context, ref, active: false),
                )
              else
                FilledButton.icon(
                  key: const Key('memberDetail.reactivate'),
                  icon: const Icon(Icons.person),
                  label: Text(l10n.actionReactivate),
                  onPressed: () => _setActive(context, ref, active: true),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
