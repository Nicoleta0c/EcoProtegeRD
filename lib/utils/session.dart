class Session {
  static String? _token;

  // Guardar token al iniciar sesión
  static void login(String token) {
    _token = token;
  }

  // Limpiar token al cerrar sesión
  static void logout() {
    _token = null;
  }

  // Revisar si hay sesión activa
  static bool isLoggedIn() {
    return _token != null && _token!.isNotEmpty;
  }

  // Obtener token si lo necesitas
  static String? getToken() => _token;
}
