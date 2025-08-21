import 'dart:convert';
import 'package:dio/dio.dart';

class AuthService {
  static const String baseUrl = 'https://adamix.net/medioambiente';
  static final Dio _dio = Dio();

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
      final body = {
        'cedula': cedula,
        'nombre': nombre,
        'apellido': apellido,
        'correo': correo,
        'password': password,
        'telefono': telefono,
        'matricula': matricula,
      };
      print('Request body: ${jsonEncode(body)}');
      print('Headers: ${{'Content-Type': 'application/json'}}');
      final response = await _dio.post(
        '$baseUrl/auth/register',
        data: body,
        options: Options(headers: {
          'Content-Type': 'application/json',
        }, validateStatus: (status) {
          return status! < 500;
        }),
      );
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.data}');
      print('Full response: $response');
      return {
        'success': response.statusCode == 200 || response.statusCode == 201,
        'data': response.data,
        'statusCode': response.statusCode,
      };
    } catch (e) {
      if (e is DioException) {
        print('Error: ${e.response?.statusCode} - ${e.response?.data}');
        return {
          'success': false,
          'error': e.response?.data['error'] ?? 'Error de conexión',
          'statusCode': e.response?.statusCode ?? 0,
        };
      }
      print('Error: $e');
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
      final body = {
        'correo': correo,
        'password': password,
      };
      print('Request body: ${jsonEncode(body)}');
      print('Headers: ${{'Content-Type': 'application/json'}}');
      final response = await _dio.post(
        '$baseUrl/auth/login',
        data: body,
        options: Options(headers: {
          'Content-Type': 'application/json',
        }, validateStatus: (status) {
          return status! < 500; 
        }),
      );
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.data}');
      print('Full response: $response');
      return {
        'success': response.statusCode == 200,
        'data': response.data,
        'statusCode': response.statusCode,
      };
    } catch (e) {
      if (e is DioException) {
        print('Error: ${e.response?.statusCode} - ${e.response?.data}');
        return {
          'success': false,
          'error': e.response?.data['error'] ?? 'Error de conexión',
          'statusCode': e.response?.statusCode ?? 0,
        };
      }
      print('Error: $e');
      return {
        'success': false,
        'error': 'Error de conexión: $e',
        'statusCode': 0,
      };
    }
  }
}