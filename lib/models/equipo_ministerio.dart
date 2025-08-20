class EquipoMinisterio {
  final String id;
  final String nombre;
  final String apellido;
  final String cargo;
  final String? foto;
  final String? telefono;
  final String? email;
  final String departamento;
  final String fechaCreacion;

  EquipoMinisterio({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.cargo,
    this.foto,
    this.telefono,
    this.email,
    required this.departamento,
    required this.fechaCreacion,
  });

  factory EquipoMinisterio.fromJson(Map<String, dynamic> json) {
    return EquipoMinisterio(
      id: json['id']?.toString() ?? '',
      nombre: json['nombre'] ?? '',
      apellido: json['apellido'] ?? '',
      cargo: json['cargo'] ?? '',
      foto: json['foto'],
      telefono: json['telefono'],
      email: json['email'],
      departamento: json['departamento'] ?? '',
      fechaCreacion: json['fecha_creacion'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'apellido': apellido,
      'cargo': cargo,
      'foto': foto,
      'telefono': telefono,
      'email': email,
      'departamento': departamento,
      'fecha_creacion': fechaCreacion,
    };
  }
}
