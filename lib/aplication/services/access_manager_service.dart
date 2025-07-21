import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:meetclic/presentation/widgets/modals/register_user_modal.dart';
import 'package:meetclic/presentation/widgets/modals/show_management_login_modal.dart';
import 'package:meetclic/presentation/widgets/modals/show_login_user_modal.dart';

import 'package:meetclic/infrastructure/repositories/implementations/user_repository_impl.dart';
import 'package:meetclic/domain/usecases/register_user_usecase.dart';
import 'package:meetclic/aplication/services/user_service.dart';
import 'package:meetclic/domain/models/user_registration_model.dart';
import 'package:meetclic/domain/models/user_login.dart';
import 'package:meetclic/domain/models/user_data_login.dart';

import 'package:meetclic/domain/services/session_service.dart';

import 'package:meetclic/aplication/services/user_login_service.dart';
import 'package:meetclic/domain/usecases/login_user_usecase.dart';

import 'package:meetclic/shared/models/api_response.dart';

final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

Future<ApiResponse<Map<String, dynamic>>> sendTokenToBackend(
  String idToken,
) async {
  try {
    final url = Uri.parse('https://tudominio.com/api/auth/google-mobile');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id_token': idToken}),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      return ApiResponse.fromJson(
        jsonResponse,
        (data) => data as Map<String, dynamic>,
      );
    } else {
      String backendMessage = response.body;
      try {
        final Map<String, dynamic> errorResponse = jsonDecode(response.body);
        backendMessage = errorResponse['message'] ?? backendMessage;
      } catch (_) {}

      return ApiResponse(
        success: false,
        message: 'Error ${response.statusCode}: $backendMessage',
        data: null,
      );
    }
  } catch (e) {
    return ApiResponse(success: false, message: 'Error de red: $e', data: null);
  }
}

Future<ApiResponse<Map<String, dynamic>>> loginWithGoogle() async {
  try {
    final account = await _googleSignIn.signIn();
    if (account == null) {
      return ApiResponse(
        success: false,
        message: 'Cancelado por el usuario',
        data: null,
      );
    }

    final auth = await account.authentication;
    final idToken = auth.idToken;

    if (idToken == null) {
      return ApiResponse(
        success: false,
        message: 'idToken es null',
        data: null,
      );
    }

    return await sendTokenToBackend(idToken);
  } catch (e) {
    return ApiResponse(success: false, message: 'Error: $e', data: null);
  }
}

class AccessManagerService {
  final BuildContext context;

  AccessManagerService(this.context);

  Future<ApiResponse> handleAccess(
    FutureOr<void> Function() onLoggedInAction,
  ) async {
    if (!SessionService().isLoggedIn) {
      final result = await _showManagementLoginModalWithResult();
      if (result.success) {
        await onLoggedInAction();
        return ApiResponse(
          success: true,
          message: 'Acceso concedido',
          data: null,
        );
      } else {
        return result;
      }
    } else {
      await onLoggedInAction();
      return ApiResponse(
        success: true,
        message: 'Acceso concedido',
        data: null,
      );
    }
  }

  Future<ApiResponse> _showManagementLoginModalWithResult() async {
    final completer = Completer<ApiResponse>();

    showManagementLoginModal(context, {
      'google': () async {
        final result = await loginWithGoogle();
        if (result.success) {
          Navigator.pop(context); // Cierra modal principal
        }
        completer.complete(result);
      },
      'facebook': () {
        completer.complete(
          ApiResponse(
            success: false,
            message: 'Login con Facebook no implementado',
            data: null,
          ),
        );
      },
      'login': () async {
        final result = await showLoginUserModal(context, (
          ctxModal,
          model,
        ) async {
          final repository = UserRepositoryImpl();
          final useCase = LoginUseCase(repository);
          final userService = UserLoginService(useCase);

          final response = await userService.loginUseCase(model);

          if (response.success) {
            Fluttertoast.showToast(msg: "Login exitoso");
            var userDataMap = response.data['userData'] as Map<String, dynamic>;
            final userDataMapManagement = UserDataLogin.fromJson(userDataMap);
            SessionService().saveSession(userDataMapManagement);
          } else {
            Fluttertoast.showToast(
              msg: response.message ?? "Error al iniciar sesión",
            );
          }

          return response.success; // ✅ Devuelve bool al modal
        });

        if (result) {
          Navigator.pop(
            context,
          ); // ✅ Cierra el modal principal si login exitoso
          completer.complete(
            ApiResponse(
              success: true,
              message: 'Login realizado correctamente.',
              data: null,
            ),
          );
        } else {
          completer.complete(
            ApiResponse(
              success: false,
              message: 'No se pudo iniciar sesión.',
              data: null,
            ),
          );
        }
      },
      'signup': () {
        showRegisterUserModal(context, (ctxModal, user) async {
          final repository = UserRepositoryImpl();
          final useCase = RegisterUserUseCase(repository);
          final userService = UserService(useCase);
          final userSend = UserRegistrationLoginModel(
            email: user.email,
            password: user.password,
            name: user.nombres,
            last_name: user.apellidos,
            birthdate: user.fechaNacimiento,
          );
          final response = await userService.register(userSend);
          if (response.success) {
            Fluttertoast.showToast(msg: "Registro exitoso");
            //      Navigator.pop(ctxModal); // Cierra modal de registro
            Navigator.pop(context); // Cierra modal principal
          } else {
            Fluttertoast.showToast(msg: "Error al registrar");
          }
          completer.complete(
            ApiResponse(
              success: response.success,
              message: response.message,
              data: null,
            ),
          );

          return response.success;
        });
      },
    });

    return completer.future;
  }
}
