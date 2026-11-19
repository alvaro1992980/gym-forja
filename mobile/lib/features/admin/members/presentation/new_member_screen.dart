import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/models/enums.dart';
import '../../../../core/models/money.dart';
import '../../../../core/network/error_messages.dart';
import '../../../../core/utils/clock.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/tier_badge.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../shared/labels.dart';
import '../../shared/payment_widgets.dart';
import '../../shared/temporary_password_screen.dart';
import '../data/members_repository.dart';
import '../domain/member_models.dart';
import 'member_form_fields.dart';
import 'members_providers.dart';

/// New member stepper (section 9.3 #3): personal data → membership →
/// payment → summary → temporary password.
class NewMemberScreen extends ConsumerStatefulWidget {
  const NewMemberScreen({super.key});

  @override
  ConsumerState<NewMemberScreen> createState() => _NewMemberScreenState();
}

class _NewMemberScreenState extends ConsumerState<NewMemberScreen> {
  final _personalForm = GlobalKey<FormState>();
  final _paymentForm = GlobalKey<FormState>();
  final _profile = MemberProfileControllers();
  final _amount = TextEditingController();
  final _note = TextEditingController();
  final _sync = SuggestedAmountSync();

  int _step = 0;
  Tier _tier = Tier.basic;
  int _months = 1;
  late DateTime _startDate = ref.read(clockProvider).today();
  PaymentMethod? _method = PaymentMethod.cash;
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _profile.dispose();
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  NewMemberPreviewProvider get _previewProvider => newMemberPreviewProvider(
    tier: _tier,
    months: _months,
    startDate: toApiDate(_startDate),
  );

  int? get _suggestedCents {
    final preview = ref.read(_previewProvider).value;
    return preview == null ? null : Money.centsFromApi(preview.suggestedAmount);
  }

  void _next() {
    final ok = switch (_step) {
      0 => _personalForm.currentState!.validate(),
      2 => _suggestedCents != null && _paymentForm.currentState!.validate(),
      _ => true,
    };
    if (ok) setState(() => _step++);
  }

  Future<void> _pickStartDate() async {
    final today = ref.read(clockProvider).today();
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      // [R-05] today − 7 days … today + 30 days.
      firstDate: today.subtract(const Duration(days: 7)),
      lastDate: today.add(const Duration(days: 30)),
    );
    if (picked != null) setState(() => _startDate = picked);
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    final p = _profile;
    final input = NewMemberInput(
      firstName: p.firstName.text.trim(),
      lastName: p.lastName.text.trim(),
      phone: p.normalizedPhone!,
      email: textOrNull(p.email),
      birthDate: p.birthDate == null ? null : toApiDate(p.birthDate!),
      gender: p.gender,
      emergencyContact: textOrNull(p.emergencyContact),
      medicalNotes: textOrNull(p.medicalNotes),
      tier: _tier,
      months: _months,
      startDate: toApiDate(_startDate),
      amountCents: Money.parseInput(_amount.text)!,
      method: _method!,
      note: textOrNull(_note),
    );
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final (member, password) = await ref
          .read(membersRepositoryProvider)
          .create(input);
      ref.invalidate(membersListProvider);
      if (!mounted) return;
      context.pushReplacement(
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
    final preview = ref.watch(_previewProvider);
    ref.listen(_previewProvider, (_, next) {
      final data = next.value;
      if (data != null) {
        _sync.apply(_amount, Money.centsFromApi(data.suggestedAmount));
      }
    });

    StepState stateOf(int i) =>
        _step > i ? StepState.complete : StepState.indexed;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.newMemberTitle)),
      body: SafeArea(
        child: Stepper(
          currentStep: _step,
          onStepTapped: (i) {
            if (i < _step) setState(() => _step = i);
          },
          controlsBuilder: (context, details) => details.stepIndex != _step
              ? const SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Row(
                    children: [
                      if (_step < 3)
                        FilledButton(
                          key: const Key('newMember.next'),
                          onPressed: _next,
                          child: Text(l10n.commonContinue),
                        )
                      else
                        FilledButton(
                          key: const Key('newMember.confirm'),
                          onPressed: _submitting ? null : _submit,
                          child: Text(l10n.newMemberConfirm),
                        ),
                      const SizedBox(width: 8),
                      if (_step > 0)
                        TextButton(
                          onPressed: _submitting
                              ? null
                              : () => setState(() => _step--),
                          child: Text(l10n.commonBack),
                        ),
                    ],
                  ),
                ),
          steps: [
            Step(
              title: Text(l10n.stepPersonal),
              state: stateOf(0),
              isActive: _step >= 0,
              content: Form(
                key: _personalForm,
                child: MemberProfileFields(
                  c: _profile,
                  clock: ref.read(clockProvider),
                  onChanged: () => setState(() {}),
                ),
              ),
            ),
            Step(
              title: Text(l10n.stepMembership),
              state: stateOf(1),
              isActive: _step >= 1,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(l10n.fieldTier),
                  TierSelector(
                    value: _tier,
                    onChanged: (t) => setState(() => _tier = t),
                  ),
                  const SizedBox(height: 16),
                  Text(l10n.fieldMonths),
                  const SizedBox(height: 8),
                  MonthsSelector(
                    value: _months,
                    onChanged: (m) => setState(() => _months = m),
                  ),
                  const SizedBox(height: 16),
                  DatePickerField(
                    label: l10n.fieldStartDate,
                    value: _startDate,
                    helperText: l10n.startDateRangeHint,
                    onTap: _pickStartDate,
                  ),
                ],
              ),
            ),
            Step(
              title: Text(l10n.stepPayment),
              state: stateOf(2),
              isActive: _step >= 2,
              content: Form(
                key: _paymentForm,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    PreviewCard(preview: preview),
                    const SizedBox(height: 16),
                    PaymentFields(
                      amount: _amount,
                      note: _note,
                      method: _method,
                      onMethodChanged: (m) => setState(() => _method = m),
                      suggestedCents: preview.value == null
                          ? null
                          : Money.centsFromApi(preview.value!.suggestedAmount),
                    ),
                  ],
                ),
              ),
            ),
            Step(
              title: Text(l10n.stepSummary),
              state: stateOf(3),
              isActive: _step >= 3,
              content: _step == 3
                  ? _summary(l10n, preview.value)
                  : const SizedBox(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summary(AppLocalizations l10n, PaymentPreview? preview) {
    final p = _profile;
    final cents = Money.parseInput(_amount.text);
    Widget row(String label, String value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: Theme.of(context).textTheme.bodySmall),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        row(
          l10n.profileFirstName,
          '${p.firstName.text.trim()} ${p.lastName.text.trim()}',
        ),
        row(l10n.profilePhone, p.normalizedPhone ?? ''),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: TierBadge(_tier),
          ),
        ),
        row(l10n.fieldMonths, l10n.paymentMonths(_months)),
        if (preview != null)
          row(
            l10n.stepMembership,
            '${formatApiDate(preview.periodStart)} – '
            '${formatApiDate(preview.periodEnd)}',
          ),
        if (cents != null) row(l10n.fieldAmount, Money.format(cents)),
        if (_method != null) row(l10n.fieldMethod, l10n.methodLabel(_method!)),
        if (textOrNull(_note) != null) row(l10n.fieldNote, _note.text.trim()),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(
            _error!,
            key: const Key('newMember.error'),
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
      ],
    );
  }
}

/// New period and suggested amount from a preview.
class PreviewCard extends StatelessWidget {
  const PreviewCard({super.key, required this.preview, this.extra});

  final AsyncValue<PaymentPreview> preview;
  final Widget? extra;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: switch (preview) {
          AsyncValue(:final PaymentPreview value, hasValue: true) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.newPeriod(
                  formatApiDate(value.periodStart),
                  formatApiDate(value.periodEnd),
                ),
                key: const Key('preview.period'),
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                l10n.suggestedAmount(
                  Money.formatApi(
                    value.suggestedAmount,
                    currency: value.currency,
                  ),
                ),
                key: const Key('preview.amount'),
              ),
              ?extra,
            ],
          ),
          AsyncValue(:final Object error, hasError: true) => Text(
            errorMessage(l10n, error),
            style: TextStyle(color: theme.colorScheme.error),
          ),
          _ => const LinearProgressIndicator(),
        },
      ),
    );
  }
}
