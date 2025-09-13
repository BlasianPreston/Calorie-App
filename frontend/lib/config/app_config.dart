class AppConfig {
  static const String apiBaseUrl = 'http://localhost:8080';
  static const String apiVersion = 'v1';
  
  static String get fullApiUrl => '$apiBaseUrl/$apiVersion';
}

