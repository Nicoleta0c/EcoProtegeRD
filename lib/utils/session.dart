class Session {
  static String? _token;
  static Map<String, dynamic>? _userInfo;

  // Guardar token y información del usuario al iniciar sesión
  static void login(String token, {Map<String, dynamic>? userInfo}) {
    _token = token;
    _userInfo = userInfo;
  }

  // Limpiar token y información del usuario al cerrar sesión
  static void logout() {
    _token = null;
    _userInfo = null;
  }

  // Revisar si hay sesión activa
  static bool isLoggedIn() {
    return _token != null && _token!.isNotEmpty;
  }

  // Obtener token si lo necesitas
  static String? getToken() => _token;

  // Obtener información del usuario
  static Map<String, dynamic>? getUserInfo() => _userInfo;

  // Obtener nombre del usuario
  static String getUserName() {
    if (_userInfo != null) {
      final nombre = _userInfo!['nombre'] ?? '';
      final apellido = _userInfo!['apellido'] ?? '';
      return '$nombre $apellido'.trim();
    }
    return 'Usuario';
  }

  // Obtener email del usuario
  static String getUserEmail() {
    return _userInfo?['correo'] ?? 'Sin email';
  }

  // Obtener cédula del usuario
  static String getUserCedula() {
    return _userInfo?['cedula'] ?? '';
  }
}
