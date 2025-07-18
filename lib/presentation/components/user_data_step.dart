import 'package:flutter/material.dart';
import 'package:meetclic/aplication/controllers/user_registration_form_controller.dart';
import '../widgets/atoms/input_text_atom.dart';
import 'package:meetclic/shared/localization/app_localizations.dart';

class UserDataStep extends StatelessWidget {
  final UserRegistrationFormController controller;

  const UserDataStep({required this.controller, super.key});

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);

    return Form(
      key: controller.formKeyStep1,
      child: Column(
        children: [
          InputTextAtom(
            label: appLocalizations.translate('loginManagerTitle.fieldEmail'),
            controller: controller.emailController,
            validator: (value) {
              if (value == null || value.isEmpty) return appLocalizations.translate('loginManagerTitle.fieldEmailInput');
              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value))
                return 'Correo inválido';
              return null;
            },
          ),
          InputTextAtom(
            label: appLocalizations.translate('loginManagerTitle.fieldPassword'),
            controller: controller.passwordController,
            obscureText: true,
            validator: (value) => value != null && value.length >= 6
                ? null
                : 'Mínimo 6 caracteres',
          ),
          InputTextAtom(
            label: appLocalizations.translate('loginManagerTitle.register.fieldPasswordRepeat'),
            controller: controller.repeatPasswordController,
            obscureText: true,
            validator: (value) => value == controller.passwordController.text
                ? null
                : appLocalizations.translate('loginManagerTitle.register.fieldPasswordRepeatError'),
          ),
        ],
      ),
    );
  }
}
