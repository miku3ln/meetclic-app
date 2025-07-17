import 'package:flutter/material.dart';

import 'package:meetclic/aplication/controllers/user_registration_form_controller.dart';
import '../widgets/atoms/input_text_atom.dart';
import '../widgets/atoms/date_picker_atom.dart';

class PersonalDataStep extends StatelessWidget {
  final UserRegistrationFormController controller;

  const PersonalDataStep({required this.controller, super.key});

  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.formKeyStep2,
      child: Column(
        children: [
          InputTextAtom(
            label: 'Nombres',
            controller: controller.nombresController,
            validator: (value) => value != null && value.isNotEmpty ? null : 'Campo requerido',
          ),
          const SizedBox(height: 12),
          InputTextAtom(
            label: 'Apellidos',
            controller: controller.apellidosController,
            validator: (value) => value != null && value.isNotEmpty ? null : 'Campo requerido',
          ),
          const SizedBox(height: 12),
          DatePickerAtom(
            label: 'Fecha de nacimiento',
            selectedDateText: controller.fechaNacimiento == null
                ? null
                : '${controller.fechaNacimiento!.day}/${controller.fechaNacimiento!.month}/${controller.fechaNacimiento!.year}',
            onDateSelected: (picked) {
              controller.fechaNacimiento = picked;
            },
          ),
        ],
      ),
    );
  }
}
