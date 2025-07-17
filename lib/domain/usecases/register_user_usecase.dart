import '../models/user_registration_model.dart';
import '../models/api_response_model.dart';
import '../viewmodels/api_response_viewmodel.dart';
import '../repositories/user_repository.dart';

class RegisterUserUseCase {
  final UserRepository repository;

  RegisterUserUseCase(this.repository);

  Future<ApiResponseModel<ApiResponseViewModel>> call(
      UserRegistrationLoginModel user,
  ) {
    return repository.registerUser(user);
  }
}
