import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/service.dart';
import '../models/noticia.dart';
import '../models/video.dart';
import '../models/area_protegida.dart';
import '../models/medida_ambiental.dart';
import '../models/equipo_ministerio.dart';
import '../models/voluntario.dart';
import 'local_database_service.dart';

class ApiService {
  static const String baseUrl = 'https://adamix.net/medioambiente';
  // Proxy CORS para desarrollo web
  static const String corsProxy = 'https://cors-anywhere.herokuapp.com/';

  // URL con proxy para web
  static String get apiUrl => kIsWeb ? '$corsProxy$baseUrl' : baseUrl;

  // Obtener lista de servicios
  static Future<List<Service>> getServices() async {
    // En web, usar datos locales para evitar CORS
    if (kIsWeb) {
      return _getDefaultServices();
    }

    try {
      final response = await http.get(
        Uri.parse('$apiUrl/servicios'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> servicesData = json.decode(response.body);
        return servicesData.map((json) => Service.fromJson(json)).toList();
      } else {
        return _getDefaultServices();
      }
    } catch (e) {
      return _getDefaultServices();
    }
  } // Servicios por defecto para evitar problemas de CORS

  static List<Service> _getDefaultServices() {
    return [
      Service(
        id: '000001',
        nombre: 'Permisos Ambientales',
        descripcion:
            'Gestión y tramitación de permisos ambientales para proyectos y actividades que impactan el medio ambiente.',
        icono: '🌱',
        fechaCreacion: DateTime.now().toIso8601String(),
      ),
      Service(
        id: '000002',
        nombre: 'Evaluación de Impacto Ambiental',
        descripcion:
            'Evaluación técnica de proyectos para determinar su impacto en el medio ambiente.',
        icono: '📋',
        fechaCreacion: DateTime.now().toIso8601String(),
      ),
      Service(
        id: '000003',
        nombre: 'Gestión de Recursos Naturales',
        descripcion:
            'Administración y conservación de los recursos naturales del país.',
        icono: '🏞️',
        fechaCreacion: DateTime.now().toIso8601String(),
      ),
      Service(
        id: '000004',
        nombre: 'Educación Ambiental',
        descripcion:
            'Programas educativos para concienciar sobre la protección del medio ambiente.',
        icono: '📚',
        fechaCreacion: DateTime.now().toIso8601String(),
      ),
    ];
  }

  static Future<Map<String, dynamic>> getMinistryInfo() async {
    if (kIsWeb) {
      await Future.delayed(const Duration(milliseconds: 500));
      return _getMinistryData();
    }

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      return _getMinistryData();
    } catch (e) {
      return _getMinistryData();
    }
  }

  static Map<String, dynamic> _getMinistryData() {
    return {
      'historia':
          'El Ministerio de Medio Ambiente y Recursos Naturales de la República Dominicana fue creado mediante la Ley 64-00 sobre Medio Ambiente y Recursos Naturales, con el propósito de ser la institución rectora de la gestión del medio ambiente, los ecosistemas y los recursos naturales.',
      'mision':
          'Formular, normar, aplicar y supervisar las políticas, estrategias y planes destinados a la protección y mejoramiento del medio ambiente y los recursos naturales, garantizando un desarrollo sostenible en beneficio de las presentes y futuras generaciones.',
      'vision':
          'Ser la institución líder en la protección del medio ambiente y la gestión sostenible de los recursos naturales de la República Dominicana, reconocida por su eficiencia, transparencia e innovación en el cumplimiento de su mandato constitucional.',
    };
  }

  static Future<List<Map<String, dynamic>>> getSliderContent() async {
    if (kIsWeb) {
      await Future.delayed(const Duration(milliseconds: 500));
      return _getDefaultSliderContent();
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/noticias'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> newsData = json.decode(response.body);

        return newsData
            .map(
              (item) => {
                'titulo': item['titulo'] ?? '',
                'descripcion':
                    item['resumen'] ??
                    item['contenido'] ??
                    item['descripcion'] ??
                    '',
                'imagen':
                    item['imagen'] ??
                    'https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?w=800',
              },
            )
            .toList()
            .cast<Map<String, dynamic>>();
      } else {
        return _getDefaultSliderContent();
      }
    } catch (e) {
      return _getDefaultSliderContent();
    }
  }

  static List<Map<String, dynamic>> _getDefaultSliderContent() {
    return [
      {
        'titulo': 'Protege el Medio Ambiente',
        'descripcion':
            'Juntos podemos construir un futuro más verde y sostenible para las próximas generaciones.',
        'imagen':
            'https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?w=800',
      },
      {
        'titulo': 'Conservación de la Biodiversidad',
        'descripcion':
            'Trabajamos para proteger la rica biodiversidad de República Dominicana.',
        'imagen':
            'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=800',
      },
      {
        'titulo': 'Desarrollo Sostenible',
        'descripcion':
            'Promovemos prácticas que equilibren el crecimiento económico con la protección ambiental.',
        'imagen':
            'https://images.unsplash.com/photo-1569163139394-de4e4f43e4e3?w=800',
      },
      {
        'titulo': 'Recursos Naturales',
        'descripcion':
            'Gestionamos responsablemente nuestros recursos naturales para el bienestar de todos.',
        'imagen':
            'https://images.unsplash.com/photo-1518837695005-2083093ee35b?w=800',
      },
    ];
  }

  static Future<List<Noticia>> getNoticias() async {
    if (kIsWeb) {
      await Future.delayed(const Duration(milliseconds: 500));
      return _getDefaultNoticias();
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/noticias'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> noticiasData = json.decode(response.body);
        return noticiasData.map((json) => Noticia.fromJson(json)).toList();
      } else {
        return _getDefaultNoticias();
      }
    } catch (e) {
      return _getDefaultNoticias();
    }
  }

  static Future<List<Video>> getVideos() async {
    if (kIsWeb) {
      await Future.delayed(const Duration(milliseconds: 500));
      return _getDefaultVideos();
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/videos?categoria=reciclaje'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> videosData = json.decode(response.body);
        final videos = videosData.map((json) => Video.fromJson(json)).toList();

        for (int i = 0; i < videos.length; i++) {
          videos[i] = Video(
            id: '${videos[i].id}_$i',
            titulo: videos[i].titulo,
            descripcion: videos[i].descripcion,
            url: videos[i].url,
            thumbnail: videos[i].thumbnail,
            duracion: videos[i].duracion,
            categoria: videos[i].categoria,
            fechaSubida: videos[i].fechaSubida,
          );
        }

        if (videos.isNotEmpty) {
          return videos;
        }
      }

      return _getDefaultVideos();
    } catch (e) {
      return _getDefaultVideos();
    }
  }

  // Obtener videos por categoría específica
  static Future<List<Video>> getVideosByCategory(String categoria) async {
    // En web, usar datos locales para evitar CORS
    if (kIsWeb) {
      await Future.delayed(const Duration(milliseconds: 500));
      return _getDefaultVideos()
          .where(
            (video) =>
                video.categoria?.toLowerCase().contains(
                  categoria.toLowerCase(),
                ) ??
                false,
          )
          .toList();
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/videos?categoria=$categoria'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> videosData = json.decode(response.body);
        return videosData.map((json) => Video.fromJson(json)).toList();
      } else {
        return _getDefaultVideos()
            .where(
              (video) =>
                  video.categoria?.toLowerCase().contains(
                    categoria.toLowerCase(),
                  ) ??
                  false,
            )
            .toList();
      }
    } catch (e) {
      return _getDefaultVideos()
          .where(
            (video) =>
                video.categoria?.toLowerCase().contains(
                  categoria.toLowerCase(),
                ) ??
                false,
          )
          .toList();
    }
  }

  // Noticias por defecto
  static List<Noticia> _getDefaultNoticias() {
    return [
      Noticia(
        id: '001',
        titulo: 'Campaña Nacional de Reforestación 2025',
        resumen:
            'El Ministerio lanza una ambiciosa campaña para plantar más de 1 millón de árboles en todo el país.',
        contenido:
            'Esta iniciativa busca restaurar los ecosistemas degradados y combatir los efectos del cambio climático en República Dominicana...',
        imagen:
            'https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?w=800',
        autor: 'Ministerio de Medio Ambiente',
        fechaPublicacion:
            DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        categoria: 'Reforestación',
      ),
      Noticia(
        id: '002',
        titulo: 'Nuevas Áreas Protegidas Declaradas',
        resumen:
            'Se declaran tres nuevas áreas protegidas para conservar la biodiversidad nacional.',
        contenido:
            'Las nuevas áreas protegidas abarcan ecosistemas únicos que albergan especies endémicas de la isla...',
        imagen:
            'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=800',
        autor: 'Dirección de Biodiversidad',
        fechaPublicacion:
            DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
        categoria: 'Conservación',
      ),
      Noticia(
        id: '003',
        titulo: 'Programa de Reciclaje Comunitario',
        resumen:
            'Se expande el programa de reciclaje a 50 comunidades adicionales en el país.',
        contenido:
            'El programa incluye capacitación, entrega de contenedores especializados y rutas de recolección optimizadas...',
        imagen:
            'https://images.unsplash.com/photo-1569163139394-de4e4f43e4e3?w=800',
        autor: 'División de Gestión de Residuos',
        fechaPublicacion:
            DateTime.now().subtract(const Duration(days: 7)).toIso8601String(),
        categoria: 'Reciclaje',
      ),
      Noticia(
        id: '004',
        titulo: 'Monitoreo de Calidad del Aire',
        resumen:
            'Nuevas estaciones de monitoreo mejoran el control de la calidad del aire en ciudades principales.',
        contenido:
            'Las estaciones proporcionan datos en tiempo real sobre contaminantes atmosféricos y permiten alertas tempranas...',
        imagen:
            'https://images.unsplash.com/photo-1518837695005-2083093ee35b?w=800',
        autor: 'Dirección de Calidad Ambiental',
        fechaPublicacion:
            DateTime.now().subtract(const Duration(days: 10)).toIso8601String(),
        categoria: 'Calidad del Aire',
      ),
    ];
  }

  // Videos por defecto (similares a los de la API)
  static List<Video> _getDefaultVideos() {
    return [
      Video(
        id: '000001',
        titulo: 'Cómo reciclar en casa',
        descripcion:
            'Aprende las técnicas básicas para separar y reciclar los residuos de tu hogar.',
        url: 'https://www.youtube.com/watch?v=uW9Qk0OAPio',
        thumbnail: 'https://img.youtube.com/vi/uW9Qk0OAPio/hqdefault.jpg',
        duracion: '12:45',
        categoria: 'reciclaje',
        fechaSubida: '2025-01-15 10:00:00',
      ),
      Video(
        id: '000002',
        titulo: 'Reducir, Reutilizar, Reciclar',
        descripcion:
            'Los tres pilares fundamentales para un consumo responsable y sostenible.',
        url: 'https://www.youtube.com/watch?v=YjLGIvIkbKc',
        thumbnail: 'https://img.youtube.com/vi/YjLGIvIkbKc/hqdefault.jpg',
        duracion: '8:30',
        categoria: 'reciclaje',
        fechaSubida: '2025-01-10 10:00:00',
      ),
      Video(
        id: '000003',
        titulo: 'Separación de Residuos',
        descripcion:
            'Guía completa para separar correctamente los diferentes tipos de residuos.',
        url: 'https://www.youtube.com/watch?v=hJZm1k8ixNI',
        thumbnail: 'https://img.youtube.com/vi/hJZm1k8ixNI/hqdefault.jpg',
        duracion: '6:15',
        categoria: 'reciclaje',
        fechaSubida: '2025-01-05 10:00:00',
      ),
    ];
  }

  // Obtener áreas protegidas
  static Future<List<AreaProtegida>> getAreasProtegidas() async {
    if (kIsWeb) {
      return _getDefaultAreasProtegidas();
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/areas_protegidas'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> areasData = json.decode(response.body);
        return areasData.map((json) => AreaProtegida.fromJson(json)).toList();
      } else {
        return _getDefaultAreasProtegidas();
      }
    } catch (e) {
      return _getDefaultAreasProtegidas();
    }
  }

  static List<AreaProtegida> _getDefaultAreasProtegidas() {
    return [
      AreaProtegida(
        id: '001',
        nombre: 'Parque Nacional Los Haitises',
        descripcion:
           
            'Parque nacional ubicado en la región noreste de República Dominicana.',
        ubicacion: 'Provincia de Hato Mayor',
        latitud: 19.0528,
        longitud: -69.4217,
        categoria: 'Parque Nacional',
        tamano: '1,600 km²',
        fechaCreacion: '2025-01-01',
      ),
      AreaProtegida(
        id: '002',
        nombre: 'Parque Nacional del Este',
        descripcion:
            'Parque nacional en la región sureste de la República Dominicana.',
        ubicacion: 'Provincia de La Altagracia',
        latitud: 18.3333,
        longitud: -68.8167,
        categoria: 'Parque Nacional',
        tamano: '420 km²',
        fechaCreacion: '2025-01-01',
      ),
    ];
  }

  // Obtener medidas ambientales
  static Future<List<MedidaAmbiental>> getMedidasAmbientales() async {
    if (kIsWeb) {
      return _getDefaultMedidasAmbientales();
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/medidas'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> medidasData = json.decode(response.body);
        return medidasData
            
            .map((json) => MedidaAmbiental.fromJson(json))
            
            .toList();
      } else {
        return _getDefaultMedidasAmbientales();
      }
    } catch (e) {
      return _getDefaultMedidasAmbientales();
    }
  }

  static List<MedidaAmbiental> _getDefaultMedidasAmbientales() {
    return [
      MedidaAmbiental(
        id: '001',
        titulo: 'Reducir el Consumo de Plástico',
        descripcion:
           
            'Medidas para disminuir el uso de plásticos de un solo uso.',
        contenido:
           
            'El plástico es uno de los principales contaminantes del medio ambiente...',
        categoria: 'Contaminación',
        fechaCreacion: '2025-01-01',
      ),
      MedidaAmbiental(
        id: '002',
        titulo: 'Ahorro de Energía',
        descripcion: 'Consejos para reducir el consumo energético en el hogar.',
        contenido:
            'El ahorro de energía es fundamental para reducir nuestra huella de carbono...',
        categoria: 'Energía',
        fechaCreacion: '2025-01-01',
      ),
    ];
  }

  // Obtener equipo del ministerio
  static Future<List<EquipoMinisterio>> getEquipoMinisterio() async {
    if (kIsWeb) {
      return _getDefaultEquipoMinisterio();
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/equipo'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> equipoData = json.decode(response.body);
        return equipoData
            
            .map((json) => EquipoMinisterio.fromJson(json))
            
            .toList();
      } else {
        return _getDefaultEquipoMinisterio();
      }
    } catch (e) {
      return _getDefaultEquipoMinisterio();
    }
  }

  static List<EquipoMinisterio> _getDefaultEquipoMinisterio() {
    return [
      EquipoMinisterio(
        id: '001',
        nombre: 'María',
        apellido: 'González',
        cargo: 'Ministra de Medio Ambiente',
        telefono: '809-555-0101',
        email: 'mgonzalez@medioambiente.gob.do',
        departamento: 'Dirección General',
        fechaCreacion: '2025-01-01',
      ),
      EquipoMinisterio(
        id: '002',
        nombre: 'Carlos',
        apellido: 'Rodríguez',
        cargo: 'Director de Áreas Protegidas',
        telefono: '809-555-0102',
        email: 'crodriguez@medioambiente.gob.do',
        departamento: 'Áreas Protegidas',
        fechaCreacion: '2025-01-01',
      ),
    ];
  }

  // Obtener información de voluntariado
  static Future<VoluntariadoInfo> getVoluntariadoInfo() async {
    if (kIsWeb) {
      return _getDefaultVoluntariadoInfo();
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/voluntariado'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return VoluntariadoInfo.fromJson(data);
      } else {
        return _getDefaultVoluntariadoInfo();
      }
    } catch (e) {
      return _getDefaultVoluntariadoInfo();
    }
  }

  static VoluntariadoInfo _getDefaultVoluntariadoInfo() {
    return VoluntariadoInfo(
      titulo: 'Programa de Voluntariado Ambiental',
      descripcion:
          'Únete a nuestro programa de voluntariado y contribuye a la protección del medio ambiente en República Dominicana.',
      requisitos: [
        'Ser mayor de 18 años',
        'Tener disponibilidad de al menos 4 horas semanales',
        'Compromiso con la conservación ambiental',
        'Disponibilidad para participar en actividades de campo',
      ],
      contacto: 'voluntariado@medioambiente.gob.do',
    );
  }

  // Registrar voluntario
  static Future<Map<String, dynamic>> registrarVoluntario(
    Voluntario voluntario,
  ) async {
    try {
      // Convertir todos los datos a form-encoded (todos como string)
      final formData = {
        'cedula': voluntario.cedula.toString(),
        'nombre': voluntario.nombre.toString(),
        'apellido': voluntario.apellido.toString(),
        'correo': voluntario.email.toString(),
        'password': voluntario.password.toString(),
        'telefono': voluntario.telefono.toString(),
      };

      if (kDebugMode) {
        print('Enviando datos del voluntario (form-encoded): $formData');
      }

      final response = await http.post(
        Uri.parse('$apiUrl/voluntarios'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        },
        body: formData,
      );

      if (kDebugMode) {
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Parsear respuesta exitosa
        try {
          final responseData = json.decode(response.body);
          return {
            'success': true,
            'message':
                responseData['mensaje'] ??
                'Registro exitoso. Te contactaremos pronto.',
            'data': responseData,
          };
        } catch (e) {
          return {
            'success': true,
            'message': 'Registro exitoso. Te contactaremos pronto.',
          };
        }
      } else {
        // Parsear mensaje de error de la API
        try {
          final errorData = json.decode(response.body);
          return {
            'success': false,
            'message':
                errorData['error'] ??
                'Error en el registro. Código: ${response.statusCode}',
            'statusCode': response.statusCode,
          };
        } catch (e) {
          return {
            'success': false,
            'message': 'Error en el registro. Código: ${response.statusCode}',
            'statusCode': response.statusCode,
          };
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error al registrar voluntario: $e');
      }
      return {
        'success': false,
        'message': 'Error de conexión. Intenta nuevamente.',
      };
    }
  }

  // Método para probar la conectividad de la API
  static Future<Map<String, dynamic>> testApiConnection() async {
    if (kIsWeb) {
      // En web, explicar la limitación de CORS
      return {
        'success': true,
        'message':
            'En modo web se simula la API por limitaciones de CORS. En móvil funcionará con la API real.',
        'note':
            'CORS (Cross-Origin Resource Sharing) bloquea peticiones desde navegadores a dominios externos.',
        'realApiTest': await _testRealApiFromBrowser(),
      };
    }

    try {
      // Usar datos de prueba (todos como string para form-encoded)
      final testFormData = {
        'cedula': DateTime.now().millisecondsSinceEpoch.toString().substring(3),
        'nombre': 'Test',
        'apellido': 'Usuario',
        'correo': 'test${DateTime.now().millisecondsSinceEpoch}@example.com',
        'password': 'test123',
        'telefono': '8091234567',
      };

      if (kDebugMode) {
        print('=== PROBANDO CONECTIVIDAD API (MÓVIL) ===');
        print('URL: $baseUrl/voluntarios');
        print('Datos de prueba (form-encoded): $testFormData');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/voluntarios'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        },
        body: testFormData,
      );

      if (kDebugMode) {
        print('Status: ${response.statusCode}');
        print('Response: ${response.body}');
        print('===============================');
      }

      return {
        'success': response.statusCode >= 200 && response.statusCode < 300,
        'statusCode': response.statusCode,
        'response': response.body,
        'message':
            response.statusCode >= 200 && response.statusCode < 300
                ? 'API funcionando correctamente'
                : 'API respondió con error: ${response.statusCode}',
      };
    } catch (e) {
      if (kDebugMode) {
        print('Error conectando con API: $e');
      }
      return {
        'success': false,
        'error': e.toString(),
        'message': 'No se pudo conectar con la API',
      };
    }
  }

  // Método auxiliar para probar API desde navegador
  static Future<Map<String, dynamic>> _testRealApiFromBrowser() async {
    try {
      // Intentar una petición simple primero
      final response = await http.get(
        Uri.parse('$baseUrl/servicios'),
        headers: {'Accept': 'application/json'},
      );

      return {
        'canConnect': true,
        'message': 'Puede conectar con la API (GET servicios)',
        'statusCode': response.statusCode,
      };
    } catch (e) {
      return {
        'canConnect': false,
        'message': 'Error de CORS al intentar conectar',
        'error': e.toString(),
      };
    }
  }

  // Obtener los reportes del usuario
  static Future<List<Map<String, dynamic>>> getReports([String? token]) async {
    try {
      // Si no hay token, devolver lista vacía
      if (token == null || token.isEmpty) {
        print('No token available for getReports - returning empty list');
        return [];
      }

      // Preparar headers con token requerido
      Map<String, String> headers = {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final response = await http.get(
        Uri.parse('$baseUrl/reportes'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        print(
          'Error getting reports: ${response.statusCode} - ${response.body}',
        );
        return [];
      }
    } catch (e) {
      print('Exception getting reports: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>> createReport({
    String? token, // Mantener para compatibilidad pero ya no se usa
    required String titulo,
    required String descripcion,
    required String foto,
    required double latitud,
    required double longitud,
  }) async {
    try {
      // Validar que todos los campos requeridos no estén vacíos
      if (titulo.trim().isEmpty) {
        return {
          'success': false,
          'error': 'El título es requerido y no puede estar vacío',
        };
      }

      if (descripcion.trim().isEmpty) {
        return {
          'success': false,
          'error': 'La descripción es requerida y no puede estar vacía',
        };
      }

      if (foto.trim().isEmpty) {
        return {
          'success': false,
          'error': 'La foto es requerida y no puede estar vacía',
        };
      }

      if (latitud == 0.0) {
        return {
          'success': false,
          'error': 'La latitud es requerida y no puede ser 0',
        };
      }

      if (longitud == 0.0) {
        return {
          'success': false,
          'error': 'La longitud es requerida y no puede ser 0',
        };
      }

      print('--- DEBUG CREATE REPORT LOCAL ---');
      print('Titulo: "${titulo.trim()}" (length: ${titulo.trim().length})');
      print(
        'Descripcion: "${descripcion.trim()}" (length: ${descripcion.trim().length})',
      );
      print('Foto: BASE64_STRING (${foto.trim().length} caracteres)');
      print('Latitud: $latitud');
      print('Longitud: $longitud');
      print('Guardando en base de datos local...');

      // Guardar en base de datos local
      final reportId = await LocalDatabaseService.createReport(
        titulo: titulo.trim(),
        descripcion: descripcion.trim(),
        foto: foto.trim(),
        latitud: latitud,
        longitud: longitud,
        usuario:
            'Usuario Local', // Puedes usar el token para determinar el usuario si es necesario
      );

      print('Reporte guardado con ID: $reportId');

      return {
        'success': true,
        'data': {
          'id': reportId,
          'titulo': titulo.trim(),
          'descripcion': descripcion.trim(),
          'latitud': latitud,
          'longitud': longitud,
          'message': 'Reporte creado exitosamente de forma local',
        },
      };
    } catch (e) {
      print('Error al guardar reporte local: $e');
      return {
        'success': false,
        'error': 'Error al guardar el reporte: ${e.toString()}',
      };
    }
  }

  // Nuevo método para obtener reportes locales
  static Future<List<Map<String, dynamic>>> getLocalReports() async {
    try {
      return await LocalDatabaseService.getAllReports();
    } catch (e) {
      print('Error al obtener reportes locales: $e');
      return [];
    }
  }

  // Nuevo método para obtener reportes por usuario
  static Future<List<Map<String, dynamic>>> getReportsByUser(
    String usuario,
  ) async {
    try {
      return await LocalDatabaseService.getReportsByUser(usuario);
    } catch (e) {
      print('Error al obtener reportes del usuario: $e');
      return [];
    }
  }
}
