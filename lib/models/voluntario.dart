class Voluntario {
  final String cedula;
  final String nombre;
  final String apellido;
  final String email;
  final String password;
  final String telefono;

  Voluntario({
    required this.cedula,
    required this.nombre,
    required this.apellido,
    required this.email,
    required this.password,
    required this.telefono,
  });

  factory Voluntario.fromJson(Map<String, dynamic> json) {
    return Voluntario(
      cedula: json['cedula'] ?? '',
      nombre: json['nombre'] ?? '',
      apellido: json['apellido'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      telefono: json['telefono'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cedula': cedula,
      'nombre': nombre,
      'apellido': apellido,
      'email': email,
      'password': password,
      'telefono': telefono,
    };
  }
}

class VoluntariadoInfo {
  final String titulo;
  final String descripcion;
  final List<String> requisitos;
  final String contacto;

  VoluntariadoInfo({
    required this.titulo,
    required this.descripcion,
    required this.requisitos,
    required this.contacto,
  });

  factory VoluntariadoInfo.fromJson(Map<String, dynamic> json) {
    return VoluntariadoInfo(
      titulo: json['titulo'] ?? '',
      descripcion: json['descripcion'] ?? '',
      requisitos: List<String>.from(json['requisitos'] ?? []),
      contacto: json['contacto'] ?? '',
    );
  }
}
