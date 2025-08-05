import 'package:flutter/material.dart';
import '../../../../domain/models/customer_model.dart';
import '../../grid-custome/gridview_header.dart';
import '../../grid-custome/organisms/customer_grid_row.dart';



class CustomerGridViewPage extends StatefulWidget {
  @override
  _CustomerGridViewPageState createState() => _CustomerGridViewPageState();
}

class _CustomerGridViewPageState extends State<CustomerGridViewPage> {
  List<CustomerModel> customers = [CustomerModel.empty()];

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

  bool validateFields() {
    for (var customer in customers) {
      if (customer.fullName.isEmpty || customer.documentNumber.isEmpty || customer.age == 0) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('All fields are mandatory.')));
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
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
      floatingActionButton: FloatingActionButton(
        onPressed: addCustomerRow,
        child: Icon(Icons.add),
        tooltip: 'Add Row',
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
    );
  }
}
