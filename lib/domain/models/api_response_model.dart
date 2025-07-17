class ApiResponseModel<T> {
  final bool success;
  final String message;
  final T? data;

  ApiResponseModel({required this.success, required this.message, this.data});

  factory ApiResponseModel.fromJson(
      Map<String, dynamic> json,
      T Function(Map<String, dynamic>) fromDataJson,
      ) {
    return ApiResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? fromDataJson(json['data']) : null,
    );
  }
}