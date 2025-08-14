class Noticia {
  final String? id;
  final String? titulo;
  final String? resumen;
  final String? contenido;
  final String? imagen;
  final String? autor;
  final String? fechaPublicacion;
  final String? categoria;

  Noticia({
    this.id,
    this.titulo,
    this.resumen,
    this.contenido,
    this.imagen,
    this.autor,
    this.fechaPublicacion,
    this.categoria,
  });

  factory Noticia.fromJson(Map<String, dynamic> json) {
    return Noticia(
      id: json['id']?.toString(),
      titulo: json['titulo'],
      resumen: json['resumen'],
      contenido: json['contenido'],
      imagen: json['imagen'],
      autor: json['autor'],
      fechaPublicacion: json['fecha_publicacion'] ?? json['fecha'],
      categoria: json['categoria'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'resumen': resumen,
      'contenido': contenido,
      'imagen': imagen,
      'autor': autor,
      'fecha_publicacion': fechaPublicacion,
      'categoria': categoria,
    };
  }
}
