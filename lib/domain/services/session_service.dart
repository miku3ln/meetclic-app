import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/usuario_login.dart';

class SessionService {
  static final SessionService _instance = SessionService._internal();
  factory SessionService() => _instance;
  SessionService._internal();

  UsuarioLogin? _usuarioLogin;

  /// Guardar sesión en memoria y local storage
  Future<void> saveSession(UsuarioLogin usuarioLogin) async {
    _usuarioLogin = usuarioLogin;

    final prefs = await SharedPreferences.getInstance();
    final userJson = jsonEncode({
      'information': {
        'Customer': usuarioLogin.customer.toJson(),
        'User': usuarioLogin.user.toJson(),
        'CustomerByProfile': null,
      },
      'access_token': usuarioLogin.accessToken,
    });
    await prefs.setString('usuario_login', userJson);
  }

  /// Cargar sesión desde local storage
  Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('usuario_login');
    if (userJson != null) {
      final Map<String, dynamic> jsonMap = jsonDecode(userJson);
      _usuarioLogin = UsuarioLogin.fromJson(jsonMap);
    }
  }

  UsuarioLogin? get currentSession => _usuarioLogin;
  String? get apiToken => _usuarioLogin?.accessToken;
  bool get isLoggedIn => _usuarioLogin != null;

  /// Cerrar sesión
  Future<void> clearSession() async {
    _usuarioLogin = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('usuario_login');
  }
}
