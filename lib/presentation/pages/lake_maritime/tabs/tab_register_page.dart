import 'package:flutter/material.dart';
import '../../../../domain/models/customer_model.dart';
import '../../../../infrastructure/services/maritime_departure_service.dart';
import '../../../widgets/grid-custome/gridview_header.dart';
import '../../../widgets/grid-custome/organisms/customer_grid_row.dart';
import '../../lake_maritime/lake_maritime_view_header.dart';
import '../../../../domain/models/maritime_departure_model.dart';

class TabRegisterPage extends StatefulWidget {
  const TabRegisterPage({super.key});

  @override
  State<TabRegisterPage> createState() => _TabRegisterPageState();
}

class _TabRegisterPageState extends State<TabRegisterPage> {
  List<CustomerModel> customers = [CustomerModel.empty()];
  final MaritimeDepartureService maritimeDepartureService =
  MaritimeDepartureService();

  void addCustomerRow() {
    setState(() {
      customers.add(CustomerModel.empty());
    });
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
    if (customers.isEmpty) return false;
    for (var customer in customers) {
      if (customer.fullName.isEmpty ||
          customer.documentNumber.isEmpty ) {
        return false;
      }
    }
    return true;
  }

  Future<void> saveRegisters() async {
    var model = MaritimeDepartureModel(
      businessId: 1,
      userId: 1,
      userManagementId: 5,
      arrivalTime: "2025-08-06T10:00:00",
      responsibleName: "Alex Alba",
    );
    final payload = maritimeDepartureService
        .buildMaritimeDeparturePayloadObject(customers, model);

    final sendUseCase =
    SendMaritimeDepartureUseCase(MaritimeDepartureService());
    final data = await sendUseCase.execute(payload);

    if (data.success) {
      setState(() => customers.clear());
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(data.message)));
  }

  @override
  Widget build(BuildContext context) {
    final isValid = allFieldsValid();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          LakeMaritimeViewHeader(
            nombreEmbarcacion: "Embarcación Taita Imbabura",
            fecha: "03/05/2025",
            nombreResponsable: "Cesar Iban Alba",
            identificacion: "1002954889",
            imageUrl:
            "https://meetclic.com/public/uploads/business/information/1598107770_Empresa.jpg",
          ),
          GridViewHeader(),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              itemCount: customers.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                return CustomerGridRow(
                  customer: customers[index],
                  onUpdate: (updatedCustomer) =>
                      updateCustomer(index, updatedCustomer),
                  onDelete: () => deleteCustomerRow(index),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton(
                onPressed: addCustomerRow,
                heroTag: 'addRow',
                tooltip: 'Agregar Persona',
                child: const Icon(Icons.add),
              ),
              const SizedBox(width: 16),
              FloatingActionButton.extended(
                onPressed: isValid ? saveRegisters : null,
                label: const Text('Enviar Registro Embarque'),
                icon: const Icon(Icons.save),
                heroTag: 'saveButton',
                backgroundColor: isValid ? Colors.blue : Colors.grey,
              ),
            ],
          )
        ],
      ),
    );
  }
}
