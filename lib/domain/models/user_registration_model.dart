class UserRegistrationLoginModel {
  final String email;
  final String password;
  final String nombres;
  final String apellidos;
  final DateTime birthdate;

  UserRegistrationLoginModel({
    required this.email,
    required this.password,
    required this.nombres,
    required this.apellidos,
    required this.birthdate,
  });
  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
    'nombres': nombres,
    'apellidos': apellidos,
    'birthdate': birthdate.toIso8601String(),
  };

}
