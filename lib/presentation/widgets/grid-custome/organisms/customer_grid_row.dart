import 'package:flutter/material.dart';
import '../../../../domain/models/customer_model.dart';
import '../../../components/input_text_field.dart';
import '../../../components/dropdown_selector.dart';
class CustomerGridRow extends StatefulWidget {
  final CustomerModel customer;
  final ValueChanged<CustomerModel> onUpdate;
  final VoidCallback onDelete;

  CustomerGridRow({
    required this.customer,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  _CustomerGridRowState createState() => _CustomerGridRowState();
}

class _CustomerGridRowState extends State<CustomerGridRow> {
  late TextEditingController fullNameController;
  late TextEditingController documentController;
  late TextEditingController ageController;

  @override
  void initState() {
    super.initState();
    fullNameController = TextEditingController(text: widget.customer.fullName);
    documentController = TextEditingController(text: widget.customer.documentNumber);
    ageController = TextEditingController(text: widget.customer.age != 0 ? widget.customer.age.toString() : '');
  }

  @override
  void dispose() {
    fullNameController.dispose();
    documentController.dispose();
    ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [

        Expanded(
          child: InputTextField(
            hintText: 'Document',
            controller: documentController,
            onChanged: (value) => widget.onUpdate(widget.customer.copyWith(documentNumber: value)),
          ),
        ),
        Expanded(
          child: InputTextField(
            hintText: 'Full Name',
            controller: fullNameController,
            onChanged: (value) => widget.onUpdate(widget.customer.copyWith(fullName: value)),
          ),
        ),
        Expanded(
          child: DropdownSelector(
            options: ['ADULT', 'CHILD'],
            selectedValue: widget.customer.type,
            onChanged: (value) => widget.onUpdate(widget.customer.copyWith(type: value)),
          ),
        ),
        Expanded(
          child: InputTextField(
            hintText: 'Age',
            controller: ageController,
            onChanged: (value) => widget.onUpdate(widget.customer.copyWith(age: int.tryParse(value) ?? 0)),
            keyboardType: TextInputType.number,
          ),
        ),
        IconButton(
          icon: Icon(Icons.delete, color: Colors.red),
          onPressed: widget.onDelete,
          tooltip: 'Delete Row',
        ),
      ],
    );
  }
}
