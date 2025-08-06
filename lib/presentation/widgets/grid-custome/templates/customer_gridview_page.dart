import 'package:flutter/material.dart';
import '../../../../domain/models/customer_model.dart';
import '../../grid-custome/gridview_header.dart';
import '../../grid-custome/organisms/customer_grid_row.dart';
import '../../../../infrastructure/services/maritime_departure_service.dart';

class CustomerGridViewPage extends StatefulWidget {
  @override
  _CustomerGridViewPageState createState() => _CustomerGridViewPageState();
}

class _CustomerGridViewPageState extends State<CustomerGridViewPage> {
  List<CustomerModel> customers = [CustomerModel.empty()];
  final MaritimeDepartureService maritimeDepartureService = MaritimeDepartureService();
  void addCustomerRow() {
    setState(() {
      customers.add(CustomerModel.empty());
    });
  }
  Future<void> saveRegisters() async {

    final payload = maritimeDepartureService.buildMaritimeDeparturePayloadObject(customers);

    final SendMaritimeDepartureUseCase sendMaritimeDepartureUseCase = SendMaritimeDepartureUseCase(
      MaritimeDepartureService(),
    );

    final data = await sendMaritimeDepartureUseCase.execute(payload);
    if (data.success) {
      customers = [CustomerModel.empty()];
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(data.message)),
    );

  }
  void deleteCustomerRow(int index) {
    setState(() {
      customers.removeAt(index);
    });
  }

  void updateCustomer(int index, CustomerModel updatedCustomer) {
    setState(() {
      customers[index] = updatedCustomer;
    });
  }
  bool allFieldsValid() {
    for (var customer in customers) {
      if (customer.fullName.isEmpty || customer.documentNumber.isEmpty || customer.age == 0) {
        return false;
      }
    }
    return true;
  }
  @override
  Widget build(BuildContext context) {
    bool isValid = allFieldsValid();
    return Scaffold(
      appBar: AppBar(title: Text('Customer Data Entry')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GridViewHeader(),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                itemCount: customers.length,
                separatorBuilder: (context, index) => Divider(),
                itemBuilder: (context, index) {
                  return CustomerGridRow(
                    customer: customers[index],
                    onUpdate: (updatedCustomer) => updateCustomer(index, updatedCustomer),
                    onDelete: () => deleteCustomerRow(index),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: addCustomerRow,
            heroTag: 'addRow',
            tooltip: 'Agregar Persona',
            child: Icon(Icons.add),
          ),
          const SizedBox(height: 16),
          FloatingActionButton.extended(
            onPressed: isValid ? saveRegisters : null,
            label: Text('Enviar Registro Embarque'),
            icon: Icon(Icons.save),
            heroTag: 'saveButton',
            backgroundColor: isValid ? Colors.blue : Colors.grey,
          ),
        ],
      ),
    );
  }
}