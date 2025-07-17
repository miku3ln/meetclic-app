class ApiResponseModel<T> {
  final int type;
  final bool success;
  final String message;
  final String data;

  ApiResponseModel({
    required this.type,
    required this.success,
    required this.message,
    required this.data,
  });

  factory ApiResponseModel.fromJson(
      Map<String, dynamic> json, T Function(dynamic) fromDataJson) {
    return ApiResponseModel<T>(
      type: json['type'] ?? 0,
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'],
    );
  }
}
