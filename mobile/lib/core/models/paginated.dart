/// `{ items, page, pageSize, total }` (docs/PLAN.md section 8 conventions).
class Paginated<T> {
  const Paginated({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.total,
  });

  factory Paginated.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) item,
  ) => Paginated(
    items: [
      for (final e in json['items'] as List<dynamic>)
        item(e as Map<String, dynamic>),
    ],
    page: json['page'] as int,
    pageSize: json['pageSize'] as int,
    total: json['total'] as int,
  );

  final List<T> items;
  final int page;
  final int pageSize;
  final int total;

  bool get hasMore => page * pageSize < total;
}
