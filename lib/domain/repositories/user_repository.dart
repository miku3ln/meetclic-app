import '../models/user_registration_model.dart';
import '../models/api_response_model.dart';
import '../viewmodels/api_response_viewmodel.dart';

abstract class UserRepository {
  Future<ApiResponseModel<Map<String, dynamic>>> registerUser(UserRegistrationLoginModel user);
}
