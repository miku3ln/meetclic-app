class UserRegistrationModel {
  final String email;
  final String password;
  final String nombres;
  final String apellidos;
  final DateTime fechaNacimiento;

  UserRegistrationModel({
    required this.email,
    required this.password,
    required this.nombres,
    required this.apellidos,
    required this.fechaNacimiento,
  });
}
