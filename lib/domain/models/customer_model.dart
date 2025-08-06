class CustomerModel {
  final String documentNumber;
  final String fullName;
  final String type;
  final int age;

  CustomerModel({
    required this.fullName,
    required this.documentNumber,
    required this.type,
    required this.age,
  });

  factory CustomerModel.empty() => CustomerModel(
    fullName: '',
    documentNumber: '',
    type: 'A',
    age: 0,
  );

  CustomerModel copyWith({
    String? fullName,
    String? documentNumber,
    String? type,
    int? age,
  }) {
    return CustomerModel(
      fullName: fullName ?? this.fullName,
      documentNumber: documentNumber ?? this.documentNumber,
      type: type ?? this.type,
      age: age ?? this.age,
    );
  }
}
