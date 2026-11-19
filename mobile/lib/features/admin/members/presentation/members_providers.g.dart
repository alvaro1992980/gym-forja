// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'members_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Search text and filter chips of the members list.

@ProviderFor(MemberFiltersController)
final memberFiltersControllerProvider = MemberFiltersControllerProvider._();

/// Search text and filter chips of the members list.
final class MemberFiltersControllerProvider
    extends $NotifierProvider<MemberFiltersController, MemberFilters> {
  /// Search text and filter chips of the members list.
  MemberFiltersControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'memberFiltersControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$memberFiltersControllerHash();

  @$internal
  @override
  MemberFiltersController create() => MemberFiltersController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MemberFilters value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MemberFilters>(value),
    );
  }
}

String _$memberFiltersControllerHash() =>
    r'26b2536b68b99e35bc37a64c653fb8fe54c01921';

/// Search text and filter chips of the members list.

abstract class _$MemberFiltersController extends $Notifier<MemberFilters> {
  MemberFilters build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<MemberFilters, MemberFilters>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<MemberFilters, MemberFilters>,
              MemberFilters,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Pages of `GET /admin/members` for the current filters.

@ProviderFor(MembersList)
final membersListProvider = MembersListProvider._();

/// Pages of `GET /admin/members` for the current filters.
final class MembersListProvider
    extends $AsyncNotifierProvider<MembersList, MembersListState> {
  /// Pages of `GET /admin/members` for the current filters.
  MembersListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'membersListProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$membersListHash();

  @$internal
  @override
  MembersList create() => MembersList();
}

String _$membersListHash() => r'8cb1496cb57def7971059f53090a2ef7448f4458';

/// Pages of `GET /admin/members` for the current filters.

abstract class _$MembersList extends $AsyncNotifier<MembersListState> {
  FutureOr<MembersListState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<MembersListState>, MembersListState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<MembersListState>, MembersListState>,
              AsyncValue<MembersListState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// `GET /admin/members/:id`.

@ProviderFor(memberDetail)
final memberDetailProvider = MemberDetailFamily._();

/// `GET /admin/members/:id`.

final class MemberDetailProvider
    extends
        $FunctionalProvider<
          AsyncValue<MemberDetail>,
          MemberDetail,
          FutureOr<MemberDetail>
        >
    with $FutureModifier<MemberDetail>, $FutureProvider<MemberDetail> {
  /// `GET /admin/members/:id`.
  MemberDetailProvider._({
    required MemberDetailFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'memberDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$memberDetailHash();

  @override
  String toString() {
    return r'memberDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<MemberDetail> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<MemberDetail> create(Ref ref) {
    final argument = this.argument as String;
    return memberDetail(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MemberDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$memberDetailHash() => r'66ef7e80ea1a59c3a6988500b1cf6d0283e66722';

/// `GET /admin/members/:id`.

final class MemberDetailFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<MemberDetail>, String> {
  MemberDetailFamily._()
    : super(
        retry: null,
        name: r'memberDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// `GET /admin/members/:id`.

  MemberDetailProvider call(String id) =>
      MemberDetailProvider._(argument: id, from: this);

  @override
  String toString() => r'memberDetailProvider';
}

/// Period and suggested amount for a new member.

@ProviderFor(newMemberPreview)
final newMemberPreviewProvider = NewMemberPreviewFamily._();

/// Period and suggested amount for a new member.

final class NewMemberPreviewProvider
    extends
        $FunctionalProvider<
          AsyncValue<PaymentPreview>,
          PaymentPreview,
          FutureOr<PaymentPreview>
        >
    with $FutureModifier<PaymentPreview>, $FutureProvider<PaymentPreview> {
  /// Period and suggested amount for a new member.
  NewMemberPreviewProvider._({
    required NewMemberPreviewFamily super.from,
    required ({Tier tier, int months, String startDate}) super.argument,
  }) : super(
         retry: null,
         name: r'newMemberPreviewProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$newMemberPreviewHash();

  @override
  String toString() {
    return r'newMemberPreviewProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<PaymentPreview> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PaymentPreview> create(Ref ref) {
    final argument =
        this.argument as ({Tier tier, int months, String startDate});
    return newMemberPreview(
      ref,
      tier: argument.tier,
      months: argument.months,
      startDate: argument.startDate,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is NewMemberPreviewProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$newMemberPreviewHash() => r'a5f77d388d3ec6b16ea33417a5dc8eb2c80a8053';

/// Period and suggested amount for a new member.

final class NewMemberPreviewFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<PaymentPreview>,
          ({Tier tier, int months, String startDate})
        > {
  NewMemberPreviewFamily._()
    : super(
        retry: null,
        name: r'newMemberPreviewProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Period and suggested amount for a new member.

  NewMemberPreviewProvider call({
    required Tier tier,
    required int months,
    required String startDate,
  }) => NewMemberPreviewProvider._(
    argument: (tier: tier, months: months, startDate: startDate),
    from: this,
  );

  @override
  String toString() => r'newMemberPreviewProvider';
}

/// Renewal preview [R-07]–[R-10].

@ProviderFor(renewalPreview)
final renewalPreviewProvider = RenewalPreviewFamily._();

/// Renewal preview [R-07]–[R-10].

final class RenewalPreviewProvider
    extends
        $FunctionalProvider<
          AsyncValue<PaymentPreview>,
          PaymentPreview,
          FutureOr<PaymentPreview>
        >
    with $FutureModifier<PaymentPreview>, $FutureProvider<PaymentPreview> {
  /// Renewal preview [R-07]–[R-10].
  RenewalPreviewProvider._({
    required RenewalPreviewFamily super.from,
    required (String, {Tier tier, int months}) super.argument,
  }) : super(
         retry: null,
         name: r'renewalPreviewProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$renewalPreviewHash();

  @override
  String toString() {
    return r'renewalPreviewProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<PaymentPreview> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PaymentPreview> create(Ref ref) {
    final argument = this.argument as (String, {Tier tier, int months});
    return renewalPreview(
      ref,
      argument.$1,
      tier: argument.tier,
      months: argument.months,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is RenewalPreviewProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$renewalPreviewHash() => r'8c45f53799ca9ada136a5722985ea85ffe4f0477';

/// Renewal preview [R-07]–[R-10].

final class RenewalPreviewFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<PaymentPreview>,
          (String, {Tier tier, int months})
        > {
  RenewalPreviewFamily._()
    : super(
        retry: null,
        name: r'renewalPreviewProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Renewal preview [R-07]–[R-10].

  RenewalPreviewProvider call(
    String memberId, {
    required Tier tier,
    required int months,
  }) => RenewalPreviewProvider._(
    argument: (memberId, tier: tier, months: months),
    from: this,
  );

  @override
  String toString() => r'renewalPreviewProvider';
}

/// Tier change preview [R-13]/[R-14].

@ProviderFor(tierChangePreview)
final tierChangePreviewProvider = TierChangePreviewFamily._();

/// Tier change preview [R-13]/[R-14].

final class TierChangePreviewProvider
    extends
        $FunctionalProvider<
          AsyncValue<TierChangePreview>,
          TierChangePreview,
          FutureOr<TierChangePreview>
        >
    with
        $FutureModifier<TierChangePreview>,
        $FutureProvider<TierChangePreview> {
  /// Tier change preview [R-13]/[R-14].
  TierChangePreviewProvider._({
    required TierChangePreviewFamily super.from,
    required (String, Tier) super.argument,
  }) : super(
         retry: null,
         name: r'tierChangePreviewProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$tierChangePreviewHash();

  @override
  String toString() {
    return r'tierChangePreviewProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<TierChangePreview> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<TierChangePreview> create(Ref ref) {
    final argument = this.argument as (String, Tier);
    return tierChangePreview(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is TierChangePreviewProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$tierChangePreviewHash() => r'143e97af2371cdce299d0f14f835baa63d09d7bb';

/// Tier change preview [R-13]/[R-14].

final class TierChangePreviewFamily extends $Family
    with
        $FunctionalFamilyOverride<FutureOr<TierChangePreview>, (String, Tier)> {
  TierChangePreviewFamily._()
    : super(
        retry: null,
        name: r'tierChangePreviewProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Tier change preview [R-13]/[R-14].

  TierChangePreviewProvider call(String memberId, Tier toTier) =>
      TierChangePreviewProvider._(argument: (memberId, toTier), from: this);

  @override
  String toString() => r'tierChangePreviewProvider';
}
