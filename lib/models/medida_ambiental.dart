class MedidaAmbiental {
  final String id;
  final String titulo;
  final String descripcion;
  final String contenido;
  final String? imagen;
  final String categoria;
  final String fechaCreacion;

  MedidaAmbiental({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.contenido,
    this.imagen,
    required this.categoria,
    required this.fechaCreacion,
  });

  factory MedidaAmbiental.fromJson(Map<String, dynamic> json) {
    return MedidaAmbiental(
      id: json['id']?.toString() ?? '',
      titulo: json['titulo'] ?? '',
      descripcion: json['descripcion'] ?? '',
      contenido: json['contenido'] ?? '',
      imagen: json['imagen'],
      categoria: json['categoria'] ?? '',
      fechaCreacion: json['fecha_creacion'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'descripcion': descripcion,
      'contenido': contenido,
      'imagen': imagen,
      'categoria': categoria,
      'fecha_creacion': fechaCreacion,
    };
  }
}
