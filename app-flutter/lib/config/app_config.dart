import 'package:flutter/foundation.dart';

class AppConfig {
  /// API Base URL configuration:
  /// - Web: uses localhost:8000 (same-origin or CORS-enabled)
  /// - Android Emulator: uses 10.0.2.2:8000 (routes to host machine)
  /// - iOS Simulator: uses 127.0.0.1:8000
  /// - Physical device: use your computer's LAN IP via --dart-define=API_BASE_URL
  static String get baseUrl {
    const envUrl = String.fromEnvironment('API_BASE_URL', defaultValue: '');
    if (envUrl.isNotEmpty) {
      return envUrl;
    }
    // Web builds use localhost, mobile emulators use platform-specific localhost
    if (kIsWeb) {
      return 'http://localhost:8000';
    }
    // For Android emulator, 10.0.2.2 maps to host's localhost
    return 'http://10.0.2.2:8000';
  }

  /// Enable mock data for development without backend.
  /// - Debug/profile: defaults to true (no backend needed for development)
  /// - Release: defaults to false (use real API)
  /// Override via --dart-define=USE_MOCK_DATA=true/false
  static bool get useMockData {
    // Check if explicitly set via environment
    const envMockSet = bool.hasEnvironment('USE_MOCK_DATA');
    if (envMockSet) {
      return const bool.fromEnvironment('USE_MOCK_DATA');
    }
    // Default: true for debug/profile, false for release
    return !kReleaseMode;
  }

  /// Optional demo screen to match the "phone home screen" mock in designs.
  /// - Debug/profile: defaults to false (real app starts at Splash)
  /// - Release: defaults to false (real app starts at Splash)
  /// Set SHOW_DEVICE_HOME_MOCK=true via --dart-define if you need the mock screen
  static const bool _showDeviceHomeMockDebug =
      bool.fromEnvironment('SHOW_DEVICE_HOME_MOCK', defaultValue: false);
  static const bool _showDeviceHomeMockRelease =
      bool.fromEnvironment('SHOW_DEVICE_HOME_MOCK', defaultValue: false);

  static bool get showDeviceHomeMock =>
      kReleaseMode ? _showDeviceHomeMockRelease : _showDeviceHomeMockDebug;
}
