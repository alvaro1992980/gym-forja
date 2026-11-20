import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

part 'device_actions.g.dart';

/// Platform side effects (clipboard, share sheet, calls, WhatsApp, haptics)
/// behind one interface so widget tests can replace them.
class DeviceActions {
  const DeviceActions();

  Future<void> copy(String text) =>
      Clipboard.setData(ClipboardData(text: text));

  Future<void> share(String text) =>
      SharePlus.instance.share(ShareParams(text: text));

  /// Opens the dialer. [phone] is normalized (`+59171234567`).
  Future<bool> call(String phone) => launchUrl(Uri(scheme: 'tel', path: phone));

  /// Opens a WhatsApp chat with [phone], optionally with a prefilled [text].
  Future<bool> whatsApp(String phone, {String? text}) => launchUrl(
    Uri.https('wa.me', '/${phone.replaceAll('+', '')}', {'text': ?text}),
    mode: LaunchMode.externalApplication,
  );

  /// Short vibration (e.g. a QR was read).
  Future<void> vibrate() => HapticFeedback.mediumImpact();

  /// Short sound and vibration for a new live check-in (section 9.3 #7).
  Future<void> alert() async {
    await SystemSound.play(SystemSoundType.alert);
    await HapticFeedback.vibrate();
  }
}

@Riverpod(keepAlive: true)
DeviceActions deviceActions(Ref ref) => const DeviceActions();
