import 'package:flutter/material.dart';
import 'package:meetclic/aplication/controllers/user_registration_form_controller.dart';
import '../widgets/atoms/input_text_atom.dart';

class UserDataStep extends StatelessWidget {
  final UserRegistrationFormController controller;

  const UserDataStep({required this.controller, super.key});

  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.formKeyStep1,
      child: Column(
        children: [
          InputTextAtom(
            label: 'Correo Electrónico',
            controller: controller.emailController,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Ingrese un correo';
              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value))
                return 'Correo inválido';
              return null;
            },
          ),
          InputTextAtom(
            label: 'Contraseña',
            controller: controller.passwordController,
            obscureText: true,
            validator: (value) => value != null && value.length >= 6
                ? null
                : 'Mínimo 6 caracteres',
          ),
          InputTextAtom(
            label: 'Repetir Contraseña',
            controller: controller.repeatPasswordController,
            obscureText: true,
            validator: (value) => value == controller.passwordController.text
                ? null
                : 'No coinciden',
          ),
        ],
      ),
    );
  }
}
