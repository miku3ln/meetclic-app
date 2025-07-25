// ===============================
// 📦 INFRASTRUCTURE LAYER
// ===============================

// infrastructure/config/server_config.dart
enum Environment {
  production,
  developer,
  test,
  local,
}

class ServerConfig {
 // static const String baseUrl = 'http://192.168.137.1/meetclickmanager/api';
  //static const String baseUrl = 'http://192.168.0.101/meetclickmanager/api';
  static Environment currentEnv = Environment.local;
  static String get baseUrl {
    switch (currentEnv) {
      case Environment.production:
        return 'https://meetclic.com/api';
      case Environment.developer:
        return 'http://192.168.0.101/meetclickmanager/api';
      case Environment.test:
        return 'http://192.168.137.1/meetclickmanager/api';
      case Environment.local:
        return 'http://192.168.137.1/meetclickmanager/api';
    }
  }
}
