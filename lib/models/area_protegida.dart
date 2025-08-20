class AreaProtegida {
  final String id;
  final String nombre;
  final String descripcion;
  final String ubicacion;
  final String? imagen;
  final double? latitud;
  final double? longitud;
  final String? categoria;
  final String? tamano;
  final String fechaCreacion;

  AreaProtegida({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.ubicacion,
    this.imagen,
    this.latitud,
    this.longitud,
    this.categoria,
    this.tamano,
    required this.fechaCreacion,
  });

  factory AreaProtegida.fromJson(Map<String, dynamic> json) {
    return AreaProtegida(
      id: json['id']?.toString() ?? '',
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'] ?? '',
      ubicacion: json['ubicacion'] ?? '',
      imagen: json['imagen'],
      latitud: double.tryParse(json['latitud']?.toString() ?? ''),
      longitud: double.tryParse(json['longitud']?.toString() ?? ''),
      categoria: json['categoria'],
      tamano: json['tamano'],
      fechaCreacion: json['fecha_creacion'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'ubicacion': ubicacion,
      'imagen': imagen,
      'latitud': latitud,
      'longitud': longitud,
      'categoria': categoria,
      'tamano': tamano,
      'fecha_creacion': fechaCreacion,
    };
  }
}
