import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../domain/models/user_registration_model.dart';
import '../../../domain/models/api_response_model.dart';
import '../../../domain/repositories/user_repository.dart';
import '../../config/server_config.dart';

class UserRepositoryImpl implements UserRepository {
  @override
  Future<ApiResponseModel<Map<String, dynamic>>> registerUser(UserRegistrationLoginModel user) async {
    final url = Uri.parse('${ServerConfig.baseUrl}/auth/with/meetclic/register');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(user.toJson()),
    );

    final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

    return ApiResponseModel.fromJson(
      jsonResponse,
          (data) {
        // El backend retorna data como un JSON STRING → Parsear a Map
        if (data is String) {
          try {
            return jsonDecode(data) as Map<String, dynamic>;
          } catch (e) {
            return {}; // Si no es un JSON válido, retornar mapa vacío
          }
        } else if (data is Map<String, dynamic>) {
          return data;
        } else {
          return {};
        }
      },
    );
  }
}
