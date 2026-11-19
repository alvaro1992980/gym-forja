// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Current tier prices [R-11].

@ProviderFor(tierPrices)
final tierPricesProvider = TierPricesProvider._();

/// Current tier prices [R-11].

final class TierPricesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TierPrice>>,
          List<TierPrice>,
          FutureOr<List<TierPrice>>
        >
    with $FutureModifier<List<TierPrice>>, $FutureProvider<List<TierPrice>> {
  /// Current tier prices [R-11].
  TierPricesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tierPricesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tierPricesHash();

  @$internal
  @override
  $FutureProviderElement<List<TierPrice>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<TierPrice>> create(Ref ref) {
    return tierPrices(ref);
  }
}

String _$tierPricesHash() => r'94c09558b072bb2e2bb89b94a6b428bfffc48e70';

/// Gym settings.

@ProviderFor(gymSettings)
final gymSettingsProvider = GymSettingsProvider._();

/// Gym settings.

final class GymSettingsProvider
    extends
        $FunctionalProvider<
          AsyncValue<GymSettings>,
          GymSettings,
          FutureOr<GymSettings>
        >
    with $FutureModifier<GymSettings>, $FutureProvider<GymSettings> {
  /// Gym settings.
  GymSettingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'gymSettingsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$gymSettingsHash();

  @$internal
  @override
  $FutureProviderElement<GymSettings> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<GymSettings> create(Ref ref) {
    return gymSettings(ref);
  }
}

String _$gymSettingsHash() => r'053ce7bfc143d24434e4ea9e8fa353cdfe8c6944';

/// Staff accounts for the Personal screen.

@ProviderFor(staffList)
final staffListProvider = StaffListFamily._();

/// Staff accounts for the Personal screen.

final class StaffListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<StaffMember>>,
          List<StaffMember>,
          FutureOr<List<StaffMember>>
        >
    with
        $FutureModifier<List<StaffMember>>,
        $FutureProvider<List<StaffMember>> {
  /// Staff accounts for the Personal screen.
  StaffListProvider._({
    required StaffListFamily super.from,
    required ({StaffRole? role, bool includeInactive}) super.argument,
  }) : super(
         retry: null,
         name: r'staffListProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$staffListHash();

  @override
  String toString() {
    return r'staffListProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<StaffMember>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<StaffMember>> create(Ref ref) {
    final argument = this.argument as ({StaffRole? role, bool includeInactive});
    return staffList(
      ref,
      role: argument.role,
      includeInactive: argument.includeInactive,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is StaffListProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$staffListHash() => r'4400adb0d4e2909749ca0cbbbb24dba28801b4f0';

/// Staff accounts for the Personal screen.

final class StaffListFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<StaffMember>>,
          ({StaffRole? role, bool includeInactive})
        > {
  StaffListFamily._()
    : super(
        retry: null,
        name: r'staffListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Staff accounts for the Personal screen.

  StaffListProvider call({StaffRole? role, bool includeInactive = false}) =>
      StaffListProvider._(
        argument: (role: role, includeInactive: includeInactive),
        from: this,
      );

  @override
  String toString() => r'staffListProvider';
}
