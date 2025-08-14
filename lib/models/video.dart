class Video {
  final String? id;
  final String? titulo;
  final String? descripcion;
  final String? url;
  final String? thumbnail;
  final String? duracion;
  final String? categoria;
  final String? fechaSubida;

  Video({
    this.id,
    this.titulo,
    this.descripcion,
    this.url,
    this.thumbnail,
    this.duracion,
    this.categoria,
    this.fechaSubida,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      id: json['id']?.toString(),
      titulo: json['titulo'],
      descripcion: json['descripcion'],
      url: json['url'],
      thumbnail: json['thumbnail'] ?? json['imagen'],
      duracion: json['duracion'],
      categoria: json['categoria'],
      fechaSubida:
          json['fecha_creacion'] ?? json['fecha_subida'] ?? json['fecha'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'descripcion': descripcion,
      'url': url,
      'thumbnail': thumbnail,
      'duracion': duracion,
      'categoria': categoria,
      'fecha_subida': fechaSubida,
    };
  }
}
