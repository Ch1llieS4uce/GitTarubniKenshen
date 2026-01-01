import 'package:flutter/foundation.dart';

class AppConfig {
  /// Change this for device/LAN testing or pass via --dart-define=API_BASE_URL=...
  /// For Android Emulator: use 10.0.2.2 (routes to host machine's localhost)
  /// For iOS Simulator: use 127.0.0.1
  /// For physical device: use your computer's LAN IP (e.g., 192.168.x.x)
  static const baseUrl = String.fromEnvironment('API_BASE_URL',
      defaultValue: 'http://10.0.2.2:8000');

  /// Enable mock data for development without backend
  /// Set to false when backend is available
  static const useMockData = bool.fromEnvironment('USE_MOCK_DATA',
      defaultValue: false);

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
