import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/service.dart';
import '../models/noticia.dart';
import '../models/video.dart';

class ApiService {
  static const String baseUrl = 'https://adamix.net/medioambiente';

  // Obtener lista de servicios
  static Future<List<Service>> getServices() async {
    // En web, usar datos locales para evitar CORS
    if (kIsWeb) {
      return _getDefaultServices();
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/servicios'),
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
}
