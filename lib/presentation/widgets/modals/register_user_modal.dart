import 'package:flutter/material.dart';
import 'package:meetclic/presentation/widgets/atoms/button_atom.dart';
import 'package:meetclic/presentation/widgets/atoms/input_text_atom.dart';
import 'package:meetclic/presentation/widgets/atoms/date_picker_atom.dart';
import 'package:meetclic/shared/localization/app_localizations.dart';
import 'package:meetclic/presentation/widgets/atoms/intro_logo.dart';
import 'package:meetclic/shared/themes/app_spacing.dart';

class UserRegistrationModel {
  final String email;
  final String password;
  final String nombres;
  final String apellidos;
  final DateTime fechaNacimiento;

  UserRegistrationModel({
    //HOLA
    required this.email,
    required this.password,
    required this.nombres,
    required this.apellidos,
    required this.fechaNacimiento,
  });
}

// ✅ Modal trigger con función que recibe context y modelo
void showRegisterUserModal(
  BuildContext context,
  Future<bool> Function(BuildContext, UserRegistrationModel) onSubmit,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (contextModal) => FractionallySizedBox(
      heightFactor: 0.95,
      child: _RegisterUserModal(onSubmit: onSubmit),
    ),
  );
}

// ✅ Modal corregido
class _RegisterUserModal extends StatefulWidget {
  final Future<bool> Function(BuildContext, UserRegistrationModel) onSubmit;

  const _RegisterUserModal({required this.onSubmit});

  @override
  State<_RegisterUserModal> createState() => _RegisterUserModalState();
}

class _RegisterUserModalState extends State<_RegisterUserModal> {
  int currentStep = 0;

  final _formKeyStep1 = GlobalKey<FormState>();
  final _formKeyStep2 = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController repeatPasswordController =
      TextEditingController();
  final TextEditingController nombresController = TextEditingController();
  final TextEditingController apellidosController = TextEditingController();

  DateTime? fechaNacimiento;

  bool get isStep1Valid =>
      _formKeyStep1.currentState?.validate() == true &&
      passwordController.text == repeatPasswordController.text;

  bool get isStep2Valid =>
      _formKeyStep2.currentState?.validate() == true && fechaNacimiento != null;

  Future<void> nextStep() async {
    if (currentStep == 0 && isStep1Valid) {
      setState(() => currentStep = 1);
    } else if (currentStep == 1 && isStep2Valid) {
      final shouldClose = await widget.onSubmit(
        context,
        UserRegistrationModel(
          email: emailController.text,
          password: passwordController.text,
          nombres: nombresController.text,
          apellidos: apellidosController.text,
          fechaNacimiento: fechaNacimiento!,
        ),
      );
      if (shouldClose) {
         Navigator.pop(context);
      }
    }
  }

  void previousStep() {
    if (currentStep > 0) {
      setState(() => currentStep--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
         // padding: const EdgeInsets.all(16),
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: SingleChildScrollView(
            reverse: true, // 👈 ayuda a que el scroll baje con el teclado
            child: Column(
              children: [
                Text(
                  appLocalizations.translate(
                    'loginManagerTitle.register.title',
                  ),
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Center(
                  child: IntroLogo(
                    assetPath: 'assets/login/init-login-register.png',
                    height: 250,
                  ),
                ),
                Stepper(
                  type: StepperType.vertical,
                  currentStep: currentStep,
                  onStepTapped: (index) {
                    if (index == 1 && isStep1Valid) {
                      setState(() => currentStep = 1);
                    } else if (index == 0) {
                      setState(() => currentStep = 0);
                    }
                  },
                  controlsBuilder: (context, _) => const SizedBox.shrink(),
                  steps: [
                    Step(
                      title: Text(
                        appLocalizations.translate(
                          'loginManagerTitle.register.stepOne',
                        ),
                      ),
                      isActive: true,
                      content: Form(
                        key: _formKeyStep1,
                        child: Column(
                          children: [
                            AppSpacing.spaceBetweenInputs,
                            InputTextAtom(
                              label: appLocalizations.translate(
                                'loginManagerTitle.fieldEmail',
                              ),
                              controller: emailController,
                              validator: (value) {
                                if (value == null || value.isEmpty)
                                  return appLocalizations.translate(
                                    'loginManagerTitle.fieldEmailInput',
                                  );
                                if (!RegExp(
                                  r'^[^@]+@[^@]+\.[^@]+',
                                ).hasMatch(value))
                                  return 'Correo inválido';
                                return null;
                              },
                            ),
                            AppSpacing.spaceBetweenInputs,
                            InputTextAtom(
                              label: appLocalizations.translate(
                                'loginManagerTitle.fieldPassword',
                              ),
                              controller: passwordController,
                              obscureText: true,
                              validator: (value) =>
                                  value != null && value.length >= 6
                                  ? null
                                  : 'Mínimo 6 caracteres',
                            ),
                            AppSpacing.spaceBetweenInputs,
                            InputTextAtom(
                              label: appLocalizations.translate(
                                'loginManagerTitle.register.fieldPasswordRepeat',
                              ),
                              controller: repeatPasswordController,
                              obscureText: true,
                              validator: (value) =>
                                  value == passwordController.text
                                  ? null
                                  : appLocalizations.translate(
                                      'loginManagerTitle.register.fieldPasswordRepeatError',
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Step(
                      title: Text(
                        appLocalizations.translate(
                          'loginManagerTitle.register.stepTwo',
                        ),
                      ),
                      isActive: isStep1Valid,
                      content: Form(
                        key: _formKeyStep2,
                        child: Column(
                          children: [
                            AppSpacing.spaceBetweenInputs,
                            InputTextAtom(
                              label: appLocalizations.translate(
                                'loginManagerTitle.register.fieldName',
                              ),
                              controller: nombresController,
                              validator: (value) =>
                                  value != null && value.isNotEmpty
                                  ? null
                                  : appLocalizations.translate(
                                      'loginManagerTitle.register.fieldNameInput',
                                    ),
                            ),
                            AppSpacing.spaceBetweenInputs,
                            InputTextAtom(
                              label: appLocalizations.translate(
                                'loginManagerTitle.register.fieldLastName',
                              ),
                              controller: apellidosController,
                              validator: (value) =>
                                  value != null && value.isNotEmpty
                                  ? null
                                  : appLocalizations.translate(
                                      'loginManagerTitle.register.fieldLastNameInput',
                                    ),
                            ),
                            AppSpacing.spaceBetweenInputs,
                            DatePickerAtom(
                              label: appLocalizations.translate(
                                'loginManagerTitle.register.fieldBirthday',
                              ),
                              selectedDateText: fechaNacimiento == null
                                  ? null
                                  : '${fechaNacimiento!.day}/${fechaNacimiento!.month}/${fechaNacimiento!.year}',
                              onDateSelected: (picked) =>
                                  setState(() => fechaNacimiento = picked),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    if (currentStep > 0)
                      Expanded(
                        child: ButtonAtom(
                          text: appLocalizations.translate(
                            'loginManagerTitle.register.buttonBack',
                          ),
                          onPressed: previousStep,
                        ),
                      ),
                    if (currentStep > 0) const SizedBox(width: 12),
                    Expanded(
                      child: ButtonAtom(
                        backgroundColor: isStep1Valid&&isStep2Valid
                            ? theme.colorScheme.primary
                            : theme.disabledColor,
                        text: currentStep == 1
                            ? appLocalizations.translate(
                                'loginManagerTitle.register.buttonRegister',
                              )
                            : appLocalizations.translate(
                                'loginManagerTitle.register.buttonNext',
                              ),
                        onPressed: nextStep,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
