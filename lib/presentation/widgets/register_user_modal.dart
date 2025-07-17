import 'package:flutter/material.dart';
import 'package:meetclic/presentation/widgets/atoms/button_atom.dart';
import 'package:meetclic/presentation/widgets/atoms/input_text_atom.dart';
import 'package:meetclic/presentation/widgets/atoms/date_picker_atom.dart';

class UserRegistrationModel {
  final String email;
  final String password;
  final String nombres;
  final String apellidos;
  final DateTime fechaNacimiento;

  UserRegistrationModel({
    required this.email,
    required this.password,
    required this.nombres,
    required this.apellidos,
    required this.fechaNacimiento,
  });
}

void showRegisterUserModal(BuildContext context, Function(UserRegistrationModel) onSubmit) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => FractionallySizedBox(
      heightFactor: 0.95, // Ocupa 95% de la pantalla
      child: _RegisterUserModal(onSubmit: onSubmit),
    ),
  );
}

class _RegisterUserModal extends StatefulWidget {
  final Function(UserRegistrationModel) onSubmit;

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
  final TextEditingController repeatPasswordController = TextEditingController();
  final TextEditingController nombresController = TextEditingController();
  final TextEditingController apellidosController = TextEditingController();

  DateTime? fechaNacimiento;

  bool get isStep1Valid =>
      _formKeyStep1.currentState?.validate() == true &&
          passwordController.text == repeatPasswordController.text;

  bool get isStep2Valid =>
      _formKeyStep2.currentState?.validate() == true &&
          fechaNacimiento != null;

  void nextStep() {
    if (currentStep == 0 && isStep1Valid) {
      setState(() => currentStep = 1);
    } else if (currentStep == 1 && isStep2Valid) {
      widget.onSubmit(
        UserRegistrationModel(
          email: emailController.text,
          password: passwordController.text,
          nombres: nombresController.text,
          apellidos: apellidosController.text,
          fechaNacimiento: fechaNacimiento!,
        ),
      );
      Navigator.pop(context);
    }
  }

  void previousStep() {
    if (currentStep > 0) {
      setState(() => currentStep--);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Text('Registro de Usuario', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                      title: const Text('Datos de Usuario'),
                      isActive: true,
                      content: Form(
                        key: _formKeyStep1,
                        child: Column(
                          children: [
                            InputTextAtom(
                              label: 'Correo Electrónico',
                              controller: emailController,
                              validator: (value) {
                                if (value == null || value.isEmpty) return 'Ingrese un correo';
                                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) return 'Correo inválido';
                                return null;
                              },
                            ),
                            InputTextAtom(
                              label: 'Contraseña',
                              controller: passwordController,
                              obscureText: true,
                              validator: (value) => value != null && value.length >= 6 ? null : 'Mínimo 6 caracteres',
                            ),
                            InputTextAtom(
                              label: 'Repetir Contraseña',
                              controller: repeatPasswordController,
                              obscureText: true,
                              validator: (value) => value == passwordController.text ? null : 'No coinciden',
                            ),
                          ],
                        ),
                      ),
                    ),
                    Step(
                      title: const Text('Datos Personales'),
                      isActive: isStep1Valid,
                      content: Form(
                        key: _formKeyStep2,
                        child: Column(
                          children: [
                            InputTextAtom(
                              label: 'Nombres',
                              controller: nombresController,
                              validator: (value) => value != null && value.isNotEmpty ? null : 'Campo requerido',
                            ),
                            InputTextAtom(
                              label: 'Apellidos',
                              controller: apellidosController,
                              validator: (value) => value != null && value.isNotEmpty ? null : 'Campo requerido',
                            ),
                            DatePickerAtom(
                              label: 'Fecha de nacimiento',
                              selectedDateText: fechaNacimiento == null
                                  ? null
                                  : '${fechaNacimiento!.day}/${fechaNacimiento!.month}/${fechaNacimiento!.year}',
                              onDateSelected: (picked) => setState(() => fechaNacimiento = picked),
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
                      Expanded(child: ButtonAtom(text: 'Atrás', onPressed: previousStep)),
                    if (currentStep > 0) const SizedBox(width: 12),
                    Expanded(
                      child: ButtonAtom(
                        text: currentStep == 1 ? 'Registrar' : 'Siguiente',
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