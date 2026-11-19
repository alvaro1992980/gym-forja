import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/core/auth/session_controller.dart';
import 'package:gym_app/core/models/enums.dart';
import 'package:gym_app/core/network/api_exception.dart';
import 'package:gym_app/core/router/app_router.dart';

import '../../helpers/fakes.dart';

void main() {
  SessionState signedIn(Role role, {bool mustChange = false}) =>
      SessionSignedIn(fakeUser(role: role, mustChangePassword: mustChange));

  test('while the session loads (or failed to), only the splash', () {
    expect(redirectFor(const SessionLoading(), Routes.admin), Routes.splash);
    expect(redirectFor(const SessionLoading(), Routes.splash), isNull);
    const failed = SessionRestoreFailed(
      ApiException(code: ClientErrorCode.network),
    );
    expect(redirectFor(failed, Routes.login), Routes.splash);
  });

  test('signed out: only the login screen', () {
    expect(redirectFor(const SessionSignedOut(), Routes.splash), Routes.login);
    expect(redirectFor(const SessionSignedOut(), Routes.admin), Routes.login);
    expect(redirectFor(const SessionSignedOut(), Routes.login), isNull);
  });

  test('a forced password change blocks every other screen', () {
    final s = signedIn(Role.admin, mustChange: true);
    expect(redirectFor(s, Routes.admin), Routes.changePassword);
    expect(redirectFor(s, Routes.changePassword), isNull);
  });

  test('each role lands on its own home', () {
    expect(redirectFor(signedIn(Role.admin), Routes.splash), Routes.admin);
    expect(redirectFor(signedIn(Role.trainer), Routes.login), Routes.trainer);
    expect(redirectFor(signedIn(Role.member), Routes.splash), Routes.member);
    expect(redirectFor(signedIn(Role.kiosk), Routes.splash), Routes.kiosk);
  });

  test("a route of another role redirects to the user's home", () {
    expect(redirectFor(signedIn(Role.member), Routes.admin), Routes.member);
    expect(
      redirectFor(signedIn(Role.trainer), '/admin/members'),
      Routes.trainer,
    );
    expect(redirectFor(signedIn(Role.admin), '/administrator'), Routes.admin);
    expect(redirectFor(signedIn(Role.admin), '/admin/members'), isNull);
    expect(
      redirectFor(signedIn(Role.admin), Routes.changePassword),
      Routes.admin,
    );
  });
}
