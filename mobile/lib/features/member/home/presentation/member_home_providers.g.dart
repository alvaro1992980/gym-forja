// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member_home_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(memberHome)
final memberHomeProvider = MemberHomeProvider._();

final class MemberHomeProvider
    extends
        $FunctionalProvider<
          AsyncValue<MemberHomeData>,
          MemberHomeData,
          FutureOr<MemberHomeData>
        >
    with $FutureModifier<MemberHomeData>, $FutureProvider<MemberHomeData> {
  MemberHomeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'memberHomeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$memberHomeHash();

  @$internal
  @override
  $FutureProviderElement<MemberHomeData> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<MemberHomeData> create(Ref ref) {
    return memberHome(ref);
  }
}

String _$memberHomeHash() => r'1df2091b495d7f8e1856ebbe51d6ba11ddacf4f0';
