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

import 'package:meetclic/domain/models/usuario_login.dart';
import 'package:meetclic/domain/services/session_service.dart';
import 'package:meetclic/domain/viewmodels/user_registration_error_viewmodel.dart';

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

/// ✅ Servicio unificado para controlar el acceso
class AccessManagerService {
  final BuildContext context;

  AccessManagerService(this.context);

  /// ✅ Método principal: retorna siempre ApiResponse
  Future<ApiResponse> handleAccess(
    FutureOr<void> Function() onLoggedInAction,
  ) async {
    if (!SessionService().isLoggedIn) {
      return await _showManagementLoginModalWithResult();
    } else {
      try {
        await onLoggedInAction();
        return ApiResponse(
          success: true,
          message: 'Acceso concedido',
          data: null,
        );
      } catch (e) {
        return ApiResponse(
          success: false,
          message: 'Error al ejecutar acción: $e',
          data: null,
        );
      }
    }
  }

  /// ✅ Muestra modal de gestión y espera resultado como ApiResponse
  Future<ApiResponse> _showManagementLoginModalWithResult() async {
    final completer = Completer<ApiResponse>();
    showManagementLoginModal(context, {
      'google': () async {
        final result = await loginWithGoogle();
        completer.complete(result);
      },
      'facebook': () {
        completer.complete(
          ApiResponse(
            success: false,
            message: 'Facebook login no implementado.',
            data: null,
          ),
        );
      },
      'login': () {
        showLoginUserModal(context, {
          'login': (BuildContext contextFromModal, UserLoginModel model) async {
            final repository = UserRepositoryImpl();
            final useCase = LoginUseCase(repository);
            final userService = UserLoginService(useCase);
            final userSend = model;
            final response = await userService.loginUseCase(userSend);
            if (response.success) {
              final jsonString = response.data; // Tu cadena JSON recibida}
              print(jsonString);
              Fluttertoast.showToast(
                msg: "Logead",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                backgroundColor: Colors.black87,
                textColor: Colors.white,
                fontSize: 16.0,
              );
              Navigator.pop(context);
              Navigator.pop(contextFromModal);
              var resultCurrent = true;
              completer.complete(
                ApiResponse(
                  success: resultCurrent,
                  message: 'login ok .',
                  data: null,
                ),
              );

            } else {
              var globalMessage = response.message;
              Fluttertoast.showToast(
                msg: globalMessage,
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                backgroundColor: Colors.black87,
                textColor: Colors.white,
                fontSize: 16.0,
              );
              var resultCurrent = false;
              completer.complete(
                ApiResponse(
                  success: resultCurrent,
                  message: 'login .',
                  data: null,
                ),
              );
            }
          },
        });
      },
      'signup': () {
        showRegisterUserModal(context, (contextFromModal, user) async {
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
          print('🚀 ENVIAR DATOS--------------------------');
          print(userSend.birthdate);
          print('RESPONSE --------------------------');
          print(response.message);
          if (response.success) {
            final jsonString = response.data; // Tu cadena JSON recibida}
            print(jsonString);
            // final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
            //  final usuarioLogin = UserDataLogin.fromJson(jsonMap);
            //  SessionService().saveSession(usuarioLogin);
            Fluttertoast.showToast(
              msg: "Logeado",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.black87,
              textColor: Colors.white,
              fontSize: 16.0,
            );
            Navigator.pop(context);
            Navigator.pop(contextFromModal);
            return true;
          } else {
            var jsonString = response.data;
            /*final Map<String, dynamic> jsonMap = jsonDecode(jsonString);*/
            /* final errorResponse = UserRegistrationErrorViewModel.fromJson(
              jsonMap,
            );*/
            /*    final globalMessage = errorResponse.generateGlobalMessage();*/
            var globalMessage = "";
            Fluttertoast.showToast(
              msg: globalMessage,
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.black87,
              textColor: Colors.white,
              fontSize: 16.0,
            );

            var resultCurrent = false;
            completer.complete(
              ApiResponse(
                success: resultCurrent,
                message: 'Login manual no implementado.',
                data: null,
              ),
            );
            return resultCurrent;
          }
        });
      },
    });

    return completer.future;
  }
}
