import 'package:flutter/material.dart';

import 'package:meetclic/aplication/controllers/user_registration_form_controller.dart';


import '../../components/user_data_step.dart';
import '../../components/personal_data_step.dart';


import '../../../domain/models/user_registration_model.dart';
import '../atoms/button_atom.dart';
void registerUserModal(BuildContext context, Function(UserRegistrationLoginModel) onSubmit) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => FractionallySizedBox(
      heightFactor: 0.95,
      child: RegisterUserModal(onSubmit: onSubmit),
    ),
  );
}

class RegisterUserModal extends StatefulWidget {
  final Function(UserRegistrationLoginModel) onSubmit;

  const RegisterUserModal({required this.onSubmit, super.key});

  @override
  State<RegisterUserModal> createState() => _RegisterUserModalState();
}

class _RegisterUserModalState extends State<RegisterUserModal> {
  final controller = UserRegistrationFormController();
  int currentStep = 0;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void nextStep() {
    if (currentStep == 0 && controller.isStep1Valid) {
      setState(() => currentStep = 1);
    } else if (currentStep == 1 && controller.isStep2Valid) {
      widget.onSubmit(controller.buildUser());
     // Navigator.pop(context);
    }
  }

  void previousStep() {
    if (currentStep > 0) setState(() => currentStep--);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Registro de Usuario',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Expanded(
              child: Stepper(
                type: StepperType.vertical,
                currentStep: currentStep,
                onStepTapped: (index) {
                  if (index == 1 && controller.isStep1Valid) {
                    setState(() => currentStep = 1);
                  } else if (index == 0) {
                    setState(() => currentStep = 0);
                  }
                },
                controlsBuilder: (context, _) => const SizedBox.shrink(),
                steps: [
                  Step(
                    title: const Text('Datos de Usuario'),
                    content: UserDataStep(controller: controller),
                    isActive: true,
                  ),
                  Step(
                    title: const Text('Datos Personales'),
                    content: PersonalDataStep(controller: controller),
                    isActive: controller.isStep1Valid,
                  ),
                ],
              ),
            ),
            Row(
              children: [
                if (currentStep > 0)
                  Expanded(
                      child:
                      ButtonAtom(text: 'Atrás', onPressed: previousStep)),
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
    );
  }
}

