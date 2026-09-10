import 'package:wakelock_plus/wakelock_plus.dart';

class WakelockService {
  static Future<void> enable() async {
    try {
      await WakelockPlus.enable();
    } catch (_) {}
  }

  static Future<void> disable() async {
    try {
      await WakelockPlus.disable();
    } catch (_) {}
  }

  static Future<void> applyBehavior(String behavior) async {
    if (behavior == 'keepAwake') {
      await enable();
    } else {
      await disable();
    }
  }
}
