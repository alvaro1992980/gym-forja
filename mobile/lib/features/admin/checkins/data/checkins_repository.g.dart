// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'checkins_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(checkinsRepository)
final checkinsRepositoryProvider = CheckinsRepositoryProvider._();

final class CheckinsRepositoryProvider
    extends
        $FunctionalProvider<
          CheckinsRepository,
          CheckinsRepository,
          CheckinsRepository
        >
    with $Provider<CheckinsRepository> {
  CheckinsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'checkinsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$checkinsRepositoryHash();

  @$internal
  @override
  $ProviderElement<CheckinsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CheckinsRepository create(Ref ref) {
    return checkinsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CheckinsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CheckinsRepository>(value),
    );
  }
}

String _$checkinsRepositoryHash() =>
    r'7a4476a128672ed2ccf50c5de28d76ab8ba09d1f';
