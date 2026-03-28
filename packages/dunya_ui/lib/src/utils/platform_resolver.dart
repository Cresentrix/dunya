import 'package:flutter/foundation.dart';

/// Resolves whether Cupertino styling should be used based on the
/// [adaptive] flag and the current platform.
class PlatformResolver {
  /// Returns `true` when [adaptive] is `true` **and** the platform is
  /// iOS or macOS. Returns `false` in all other cases.
  static bool useCupertino(bool adaptive) {
    if (!adaptive) return false;
    return defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS;
  }
}
