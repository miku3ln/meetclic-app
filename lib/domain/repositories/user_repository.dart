import '../models/user_registration_model.dart';
import '../models/api_response_model.dart';
import '../viewmodels/api_response_viewmodel.dart';

abstract class UserRepository {
  Future<ApiResponseModel<ApiResponseViewModel>> registerUser(UserRegistrationLoginModel user);
}
