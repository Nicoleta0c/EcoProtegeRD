class Service {
  final String? id;
  final String? nombre;
  final String? descripcion;
  final String? icono;
  final String? imagen;
  final String? url;
  final String? fechaCreacion;

  Service({
    this.id,
    this.nombre,
    this.descripcion,
    this.icono,
    this.imagen,
    this.url,
    this.fechaCreacion,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      icono: json['icono'],
      imagen: json['imagen'], // Puede ser null del API
      url: json['url'], // Puede ser null del API
      fechaCreacion: json['fecha_creacion'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'icono': icono,
      'imagen': imagen,
      'url': url,
      'fecha_creacion': fechaCreacion,
    };
  }
}
