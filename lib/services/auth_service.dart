import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = 'https://adamix.net/medioambiente';

  // Registro de usuario
  static Future<Map<String, dynamic>> register({
    required String cedula,
    required String nombre,
    required String apellido,
    required String correo,
    required String password,
    required String telefono,
    required String matricula,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'cedula': cedula,
          'nombre': nombre,
          'apellido': apellido,
          'correo': correo,
          'password': password,
          'telefono': telefono,
          'matricula': matricula,
        }),
      );

      return {
        'success': response.statusCode == 200 || response.statusCode == 201,
        'data': jsonDecode(response.body),
        'statusCode': response.statusCode,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Error de conexión: $e',
        'statusCode': 0,
      };
    }
  }

  // Login de usuario
  static Future<Map<String, dynamic>> login({
    required String correo,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'correo': correo,
          'password': password,
        }),
      );

      return {
        'success': response.statusCode == 200,
        'data': jsonDecode(response.body),
        'statusCode': response.statusCode,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Error de conexión: $e',
        'statusCode': 0,
      };
    }
  }
}
