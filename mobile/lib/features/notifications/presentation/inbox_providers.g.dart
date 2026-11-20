// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inbox_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Unread notifications of the signed-in user (the bell badge).

@ProviderFor(unreadCount)
final unreadCountProvider = UnreadCountProvider._();

/// Unread notifications of the signed-in user (the bell badge).

final class UnreadCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  /// Unread notifications of the signed-in user (the bell badge).
  UnreadCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'unreadCountProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$unreadCountHash();

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    return unreadCount(ref);
  }
}

String _$unreadCountHash() => r'116d606209e4926ed99b3b666300410267f33cfa';

/// Pages of `GET /me/notifications`, newest first.

@ProviderFor(Inbox)
final inboxProvider = InboxProvider._();

/// Pages of `GET /me/notifications`, newest first.
final class InboxProvider extends $AsyncNotifierProvider<Inbox, InboxState> {
  /// Pages of `GET /me/notifications`, newest first.
  InboxProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'inboxProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$inboxHash();

  @$internal
  @override
  Inbox create() => Inbox();
}

String _$inboxHash() => r'36688f41a19381a8cd98db72cb9cb8e75d4e5d74';

/// Pages of `GET /me/notifications`, newest first.

abstract class _$Inbox extends $AsyncNotifier<InboxState> {
  FutureOr<InboxState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<InboxState>, InboxState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<InboxState>, InboxState>,
              AsyncValue<InboxState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
