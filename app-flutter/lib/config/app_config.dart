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
}
