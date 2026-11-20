// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'realtime_client.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The admin's live connection, open while an ADMIN is signed in (other
/// roles get null: the server only sends events to admins).

@ProviderFor(realtimeConnection)
final realtimeConnectionProvider = RealtimeConnectionProvider._();

/// The admin's live connection, open while an ADMIN is signed in (other
/// roles get null: the server only sends events to admins).

final class RealtimeConnectionProvider
    extends
        $FunctionalProvider<
          RealtimeConnection?,
          RealtimeConnection?,
          RealtimeConnection?
        >
    with $Provider<RealtimeConnection?> {
  /// The admin's live connection, open while an ADMIN is signed in (other
  /// roles get null: the server only sends events to admins).
  RealtimeConnectionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'realtimeConnectionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$realtimeConnectionHash();

  @$internal
  @override
  $ProviderElement<RealtimeConnection?> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RealtimeConnection? create(Ref ref) {
    return realtimeConnection(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RealtimeConnection? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RealtimeConnection?>(value),
    );
  }
}

String _$realtimeConnectionHash() =>
    r'23a0562d54d6f1d2755ef723ff693f953040c2de';

/// Every realtime event for the signed-in admin.

@ProviderFor(realtimeEvents)
final realtimeEventsProvider = RealtimeEventsProvider._();

/// Every realtime event for the signed-in admin.

final class RealtimeEventsProvider
    extends
        $FunctionalProvider<
          AsyncValue<RealtimeEvent>,
          RealtimeEvent,
          Stream<RealtimeEvent>
        >
    with $FutureModifier<RealtimeEvent>, $StreamProvider<RealtimeEvent> {
  /// Every realtime event for the signed-in admin.
  RealtimeEventsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'realtimeEventsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$realtimeEventsHash();

  @$internal
  @override
  $StreamProviderElement<RealtimeEvent> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<RealtimeEvent> create(Ref ref) {
    return realtimeEvents(ref);
  }
}

String _$realtimeEventsHash() => r'1c49204b56ade32b5c36883a1c1c3b387b4504c5';
