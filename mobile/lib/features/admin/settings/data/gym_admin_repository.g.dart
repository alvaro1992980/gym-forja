// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gym_admin_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(gymAdminRepository)
final gymAdminRepositoryProvider = GymAdminRepositoryProvider._();

final class GymAdminRepositoryProvider
    extends
        $FunctionalProvider<
          GymAdminRepository,
          GymAdminRepository,
          GymAdminRepository
        >
    with $Provider<GymAdminRepository> {
  GymAdminRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'gymAdminRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$gymAdminRepositoryHash();

  @$internal
  @override
  $ProviderElement<GymAdminRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GymAdminRepository create(Ref ref) {
    return gymAdminRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GymAdminRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GymAdminRepository>(value),
    );
  }
}

String _$gymAdminRepositoryHash() =>
    r'9a58143ecc0129cc691c2c3168849827dd6f6e63';
