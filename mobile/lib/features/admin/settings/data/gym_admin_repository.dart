import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/models/enums.dart';
import '../../../../core/models/money.dart';
import '../../../../core/models/paginated.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';

part 'gym_admin_repository.g.dart';

/// `GET /admin/pricing` item [R-11].
class TierPrice {
  const TierPrice({
    required this.tier,
    required this.monthlyCents,
    required this.currency,
  });

  factory TierPrice.fromJson(Map<String, dynamic> json) => TierPrice(
    tier: Tier.values.byName((json['tier'] as String).toLowerCase()),
    monthlyCents: Money.centsFromApi(json['monthlyPrice'] as String),
    currency: json['currency'] as String,
  );

  final Tier tier;
  final int monthlyCents;
  final String currency;
}

/// `GET /admin/settings`.
class GymSettings {
  const GymSettings({
    required this.gymName,
    required this.timezone,
    required this.checkinCooldownMinutes,
    required this.insideWindowMinutes,
    required this.defaultCountryCode,
  });

  factory GymSettings.fromJson(Map<String, dynamic> json) => GymSettings(
    gymName: json['gymName'] as String,
    timezone: json['timezone'] as String,
    checkinCooldownMinutes: json['checkinCooldownMinutes'] as int,
    insideWindowMinutes: json['insideWindowMinutes'] as int,
    defaultCountryCode: json['defaultCountryCode'] as String,
  );

  final String gymName;
  final String timezone;
  final int checkinCooldownMinutes;
  final int insideWindowMinutes;
  final String defaultCountryCode;
}

/// Staff roles an admin can create.
enum StaffRole {
  admin,
  trainer,
  kiosk;

  String get api => name.toUpperCase();
}

/// `GET /admin/staff` item.
class StaffMember {
  const StaffMember({
    required this.id,
    required this.role,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
    required this.isActive,
  });

  factory StaffMember.fromJson(Map<String, dynamic> json) => StaffMember(
    id: json['id'] as String,
    role: StaffRole.values.byName((json['role'] as String).toLowerCase()),
    firstName: json['firstName'] as String,
    lastName: json['lastName'] as String,
    phone: json['phone'] as String,
    email: json['email'] as String?,
    isActive: json['isActive'] as bool,
  );

  final String id;
  final StaffRole role;
  final String firstName;
  final String lastName;
  final String phone;
  final String? email;
  final bool isActive;

  String get fullName => '$firstName $lastName';
}

/// Pricing, settings and staff endpoints (section 8.2/8.3).
class GymAdminRepository {
  GymAdminRepository(this._dio);

  final Dio _dio;

  Future<List<TierPrice>> prices() => apiCall(() async {
    final res = await _dio.get<List<dynamic>>('/admin/pricing');
    return [
      for (final e in res.data!) TierPrice.fromJson(e as Map<String, dynamic>),
    ]..sort((a, b) => a.tier.rank.compareTo(b.tier.rank));
  });

  Future<void> updatePrices(Map<Tier, int> monthlyCents) => apiCall(
    () => _dio.put<void>(
      '/admin/pricing',
      data: {
        'prices': [
          for (final MapEntry(:key, :value) in monthlyCents.entries)
            {'tier': key.api, 'monthlyPrice': Money.toApi(value)},
        ],
      },
    ),
  );

  Future<GymSettings> settings() => apiCall(() async {
    final res = await _dio.get<Map<String, dynamic>>('/admin/settings');
    return GymSettings.fromJson(res.data!);
  });

  Future<GymSettings> updateSettings({
    required String gymName,
    required int checkinCooldownMinutes,
    required int insideWindowMinutes,
    required String defaultCountryCode,
  }) => apiCall(() async {
    final res = await _dio.put<Map<String, dynamic>>(
      '/admin/settings',
      data: {
        'gymName': gymName,
        'checkinCooldownMinutes': checkinCooldownMinutes,
        'insideWindowMinutes': insideWindowMinutes,
        'defaultCountryCode': defaultCountryCode,
      },
    );
    return GymSettings.fromJson(res.data!);
  });

  Future<Paginated<StaffMember>> staff({
    StaffRole? role,
    bool includeInactive = false,
  }) => apiCall(() async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/admin/staff',
      queryParameters: {
        'pageSize': 100,
        'role': ?role?.api,
        if (includeInactive) 'includeInactive': true,
      },
    );
    return Paginated.fromJson(res.data!, StaffMember.fromJson);
  });

  /// Returns the account and its temporary password (shown once [R-41]).
  Future<(StaffMember, String)> createStaff({
    required StaffRole role,
    required String firstName,
    required String lastName,
    required String phone,
    String? email,
  }) => apiCall(() async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/admin/staff',
      data: {
        'role': role.api,
        'firstName': firstName,
        'lastName': lastName,
        'phone': phone,
        'email': ?email,
      },
    );
    final json = res.data!;
    return (StaffMember.fromJson(json), json['temporaryPassword'] as String);
  });

  Future<StaffMember> setStaffActive(String id, {required bool active}) =>
      apiCall(() async {
        final res = await _dio.post<Map<String, dynamic>>(
          '/admin/staff/$id/${active ? 'reactivate' : 'deactivate'}',
        );
        return StaffMember.fromJson(res.data!);
      });
}

@Riverpod(keepAlive: true)
GymAdminRepository gymAdminRepository(Ref ref) =>
    GymAdminRepository(ref.watch(dioProvider));
