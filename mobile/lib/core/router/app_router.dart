import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/admin/presentation/admin_home_screen.dart';
import '../../features/auth/presentation/change_password_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/kiosk/presentation/kiosk_home_screen.dart';
import '../../features/member/home/presentation/member_home_screen.dart';
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

@Riverpod(keepAlive: true)
GoRouter router(Ref ref) {
  final refresh = ValueNotifier<int>(0);
  ref.listen(sessionControllerProvider, (_, _) => refresh.value++);

  final router = GoRouter(
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
      GoRoute(path: Routes.admin, builder: (_, _) => const AdminHomeScreen()),
      GoRoute(
        path: Routes.trainer,
        builder: (_, _) => const TrainerHomeScreen(),
      ),
      GoRoute(path: Routes.member, builder: (_, _) => const MemberHomeScreen()),
      GoRoute(path: Routes.kiosk, builder: (_, _) => const KioskHomeScreen()),
    ],
  );
  ref.onDispose(() {
    router.dispose();
    refresh.dispose();
  });
  return router;
}
