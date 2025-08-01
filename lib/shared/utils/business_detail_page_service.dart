
import 'package:meetclic/domain/usecases/get_nearby_businesses_usecase.dart';
import 'package:meetclic/infrastructure/repositories/implementations/business_repository_impl.dart';
import 'package:meetclic/domain/models/api_response_model.dart';
import 'package:meetclic/domain/models/business_model.dart';

Future<ApiResponseModel<List<BusinessModel>>> _loadBusinessesDetails(
    businessId,
    ) async {
  final useCase = BusinessesDetailsUseCase(
    repository: BusinessDetailsRepositoryImpl(),
  );

  final response = await useCase.execute(businessId: businessId);
  return response;
}
