/// Runs futures in parallel and rethrows the first error as is (a record's
/// `.wait` wraps errors in `ParallelWaitError`, hiding the `ApiException`).
Future<(A, B)> both<A, B>(Future<A> a, Future<B> b) async {
  final r = await Future.wait<Object?>([a, b]);
  return (r[0] as A, r[1] as B);
}

/// Three-future version of [both].
Future<(A, B, C)> all3<A, B, C>(Future<A> a, Future<B> b, Future<C> c) async {
  final r = await Future.wait<Object?>([a, b, c]);
  return (r[0] as A, r[1] as B, r[2] as C);
}
