import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/admin/checkins/presentation/live_checkins_screen.dart';
import '../../features/admin/members/presentation/edit_member_screen.dart';
import '../../features/admin/members/presentation/member_detail_screen.dart';
import '../../features/admin/members/presentation/members_list_screen.dart';
import '../../features/admin/members/presentation/new_member_screen.dart';
import '../../features/admin/members/presentation/renew_screen.dart';
import '../../features/admin/members/presentation/tier_change_screen.dart';
import '../../features/admin/presentation/admin_home_screen.dart';
import '../../features/admin/presentation/admin_shell.dart';
import '../../features/admin/settings/presentation/more_screen.dart';
import '../../features/admin/settings/presentation/pricing_screen.dart';
import '../../features/admin/settings/presentation/settings_screen.dart';
import '../../features/admin/shared/temporary_password_screen.dart';
import '../../features/admin/staff/presentation/staff_screens.dart';
import '../../features/auth/presentation/change_password_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/kiosk/presentation/kiosk_home_screen.dart';
import '../../features/member/checkin/domain/checkin_result.dart';
import '../../features/member/checkin/presentation/checkin_result_screen.dart';
import '../../features/member/checkin/presentation/scanner_screen.dart';
import '../../features/member/home/presentation/member_home_screen.dart';
import '../../features/notifications/presentation/inbox_screen.dart';
import '../../features/trainer/presentation/trainer_home_screen.dart';
import '../auth/session_controller.dart';
import '../models/enums.dart';

part 'app_router.g.dart';

abstract final class Routes {
  static const splash = '/splash';
  static const login = '/login';
  static const changePassword = '/change-password';
  static const admin = '/admin';
  static const trainer = '/trainer';
  static const member = '/member';
  static const kiosk = '/kiosk';

  /// The inbox inside [role]'s area.
  static String notificationsFor(Role role) => '${homeFor(role)}/notifications';

  static String homeFor(Role role) => switch (role) {
    Role.admin => admin,
    Role.trainer => trainer,
    Role.member => member,
    Role.kiosk => kiosk,
  };
}

/// Where the user must be for [location] given the [session]; null keeps
/// them there (docs/PLAN.md section 9.2):
///  - while the session is being restored (or failed to), only the splash;
///  - signed out: only the login screen;
///  - a pending forced password change: only that screen;
///  - signed in: only their own role's area; anything else → their home.
String? redirectFor(SessionState session, String location) {
  String? only(String route) => location == route ? null : route;

  switch (session) {
    case SessionLoading() || SessionRestoreFailed():
      return only(Routes.splash);
    case SessionSignedOut():
      return only(Routes.login);
    case SessionSignedIn(:final user):
      if (user.mustChangePassword) return only(Routes.changePassword);
      final home = Routes.homeFor(user.role);
      final inOwnArea = location == home || location.startsWith('$home/');
      return inOwnArea ? null : home;
  }
}

/// The app's top navigator (full-screen pages and app-wide dialogs).
final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

/// Full-screen admin page above the bottom navigation.
GoRoute _fullScreen(String path, Widget Function(GoRouterState s) build) =>
    GoRoute(
      path: path,
      parentNavigatorKey: rootNavigatorKey,
      builder: (_, state) => build(state),
    );

@Riverpod(keepAlive: true)
GoRouter router(Ref ref) {
  final refresh = ValueNotifier<int>(0);
  ref.listen(sessionControllerProvider, (_, _) => refresh.value++);

  final router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: Routes.splash,
    refreshListenable: refresh,
    redirect: (context, state) =>
        redirectFor(ref.read(sessionControllerProvider), state.matchedLocation),
    routes: [
      GoRoute(path: Routes.splash, builder: (_, _) => const SplashScreen()),
      GoRoute(path: Routes.login, builder: (_, _) => const LoginScreen()),
      GoRoute(
        path: Routes.changePassword,
        builder: (_, _) => const ChangePasswordScreen(),
      ),
      ..._adminRoutes(),
      GoRoute(
        path: Routes.trainer,
        builder: (_, _) => const TrainerHomeScreen(),
        routes: [_inboxRoute()],
      ),
      GoRoute(
        path: Routes.member,
        builder: (_, _) => const MemberHomeScreen(),
        routes: [
          _inboxRoute(),
          GoRoute(path: 'scan', builder: (_, _) => const ScannerScreen()),
          GoRoute(
            path: 'checkin-result',
            redirect: (_, state) =>
                state.extra is CheckinOutcome ? null : Routes.member,
            builder: (_, state) =>
                CheckinResultScreen(outcome: state.extra! as CheckinOutcome),
          ),
        ],
      ),
      GoRoute(path: Routes.kiosk, builder: (_, _) => const KioskHomeScreen()),
    ],
  );
  ref.onDispose(() {
    router.dispose();
    refresh.dispose();
  });
  return router;
}

GoRoute _inboxRoute() => GoRoute(
  path: 'notifications',
  parentNavigatorKey: rootNavigatorKey,
  builder: (_, _) => const InboxScreen(),
);

List<RouteBase> _adminRoutes() => [
  StatefulShellRoute.indexedStack(
    builder: (_, _, shell) => AdminShell(shell: shell),
    branches: [
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: Routes.admin,
            builder: (_, _) => const AdminHomeScreen(),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: '/admin/members',
            builder: (_, _) => const MembersListScreen(),
            routes: [
              _fullScreen('new', (_) => const NewMemberScreen()),
              GoRoute(
                path: ':id',
                builder: (_, s) =>
                    MemberDetailScreen(memberId: s.pathParameters['id']!),
                routes: [
                  _fullScreen(
                    'renew',
                    (s) => RenewScreen(memberId: s.pathParameters['id']!),
                  ),
                  _fullScreen(
                    'tier-change',
                    (s) => TierChangeScreen(memberId: s.pathParameters['id']!),
                  ),
                  _fullScreen(
                    'edit',
                    (s) => EditMemberScreen(memberId: s.pathParameters['id']!),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: '/admin/checkins',
            builder: (_, _) => const LiveCheckinsScreen(),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: '/admin/plans',
            builder: (_, _) => ComingSoonScreen(title: (l) => l.navPlans),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: '/admin/more',
            builder: (_, _) => const MoreScreen(),
            routes: [
              GoRoute(
                path: 'pricing',
                builder: (_, _) => const PricingScreen(),
              ),
              GoRoute(
                path: 'staff',
                builder: (_, _) => const StaffListScreen(),
                routes: [_fullScreen('new', (_) => const NewStaffScreen())],
              ),
              GoRoute(
                path: 'settings',
                builder: (_, _) => const SettingsScreen(),
              ),
              GoRoute(
                path: 'profile',
                builder: (_, _) => const AdminProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  ),
  GoRoute(
    path: '/admin/notifications',
    parentNavigatorKey: rootNavigatorKey,
    builder: (_, _) => const InboxScreen(),
  ),
  GoRoute(
    path: '/admin/temporary-password',
    parentNavigatorKey: rootNavigatorKey,
    redirect: (_, state) =>
        state.extra is TemporaryPasswordArgs ? null : Routes.admin,
    builder: (_, state) =>
        TemporaryPasswordScreen(args: state.extra! as TemporaryPasswordArgs),
  ),
];
