import 'package:flutter/material.dart';
import '../../../../domain/models/customer_model.dart';
import '../widgets/grid-custome/gridview_header.dart';
import '../widgets/grid-custome/organisms/customer_grid_row.dart';
import '../../../../infrastructure/services/maritime_departure_service.dart';
import 'package:meetclic/domain/entities/menu_tab_up_item.dart';
import '../../../presentation/widgets/template/custom_app_bar.dart';
import 'dart:async';
import 'package:intl/intl.dart';
class ProjectLakePage extends StatefulWidget {
  final String title;
  final List<MenuTabUpItem> itemsStatus;

  const ProjectLakePage({
    super.key,
    required this.title,
    required this.itemsStatus,
  });

  @override
  _ProjectLakePageState createState() => _ProjectLakePageState();
}

class _ProjectLakePageState extends State<ProjectLakePage>
    with TickerProviderStateMixin {
  List<CustomerModel> customers = [CustomerModel.empty()];
  final MaritimeDepartureService maritimeDepartureService =
  MaritimeDepartureService();

  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // Redibuja para actualizar FAB según el tab
    });
  }

  void addCustomerRow() {
    setState(() {
      customers.add(CustomerModel.empty());
    });
  }

  Future<void> saveRegisters() async {
    final payload =
    maritimeDepartureService.buildMaritimeDeparturePayloadObject(customers,  {
      "business_id": 1,
      "user_id": 999,
      "user_management_id": 5,
      "arrival_time": "2025-08-06 10:00:00",
      "responsible_name": "Alex Alba"
    });

    final sendUseCase = SendMaritimeDepartureUseCase(MaritimeDepartureService());
    final data = await sendUseCase.execute(payload);

    if (data.success) {
      resetGrid();
    }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data.message)));
  }

  void deleteCustomerRow(int index) {
    setState(() {
      customers.removeAt(index);
    });
  }

  void resetGrid() {
    setState(() {
      customers = [CustomerModel.empty()];
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
          customer.documentNumber.isEmpty ||
          customer.age == 0) {
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isValid = allFieldsValid();
    final int indexHome=0;
    final int indexRegister=1;
    final int indexRegisters=2;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(title: widget.title, items: widget.itemsStatus),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            indicatorColor: theme.primaryColor,
            labelColor: theme.primaryColor,
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(icon: Icon(Icons.home), text: "Inicio"),
              Tab(icon: Icon(Icons.assignment), text: "Registro"),
              Tab(icon: Icon(Icons.list), text: "Registros"),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Inicio
                Center(child: Text("Bienvenido a la sección de inicio")),

                // Tab 2: Registro
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      LakeMaritimeViewHeader(
                        nombreEmbarcacion: "Embarcación Taita Imbabura",
                        fecha: "03/05/2025",
                        nombreResponsable: "Cesar Iban Alba",
                        identificacion: "1002954889",
                        imageUrl: "https://meetclic.com/public/uploads/business/information/1598107770_Empresa.jpg", // 👈 Puedes usar cualquier imagen HTTP/HTTPS
                      ),

                      GridViewHeader(),
                      const SizedBox(height: 8),
                      Expanded(
                        child: ListView.separated(
                          itemCount: customers.length,
                          separatorBuilder: (context, index) => Divider(),
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
                    ],
                  ),
                ),
                // Tab 3: Registros
                Center(child: Text("Listado de registros enviados")),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _tabController.index == indexRegister
          ? Column(
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
      )
          : null,
    );
  }
}





class LakeMaritimeViewHeader extends StatefulWidget {
  final String nombreEmbarcacion;
  final String fecha;
  final String nombreResponsable;
  final String identificacion;
  final String imageUrl;

  const LakeMaritimeViewHeader({
    super.key,
    required this.nombreEmbarcacion,
    required this.fecha,
    required this.nombreResponsable,
    required this.identificacion,
    required this.imageUrl,
  });

  @override
  State<LakeMaritimeViewHeader> createState() => _LakeMaritimeViewHeaderState();
}

class _LakeMaritimeViewHeaderState extends State<LakeMaritimeViewHeader> {
  late String horaActual;
  late Timer timer;

  @override
  void initState() {
    super.initState();
    _actualizarHora();
    timer = Timer.periodic(const Duration(seconds: 1), (_) => _actualizarHora());
  }

  void _actualizarHora() {
    final now = DateTime.now();
    final formatted = DateFormat('hh:mm a').format(now); // ej: 04:52 PM
    setState(() {
      horaActual = formatted;
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final imageSize = availableWidth * 0.15; // 15% para la imagen

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 1),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen circular
              ClipOval(
                child: Image.network(
                  widget.imageUrl,
                  width: imageSize,
                  height: imageSize,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: imageSize,
                      height: imageSize,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black),
                      ),
                      child: const Icon(Icons.error, color: Colors.red),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),

              // Información
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.nombreEmbarcacion.toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),

                    Wrap(
                      spacing: 20,
                      runSpacing: 8,
                      children: [
                        _infoItem("FECHA", widget.fecha),
                        _infoItem("HORA", horaActual),
                        _infoItem("RESPONSABLE", widget.nombreResponsable),
                        _infoItem("IDENTIFICACION", widget.identificacion),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _infoItem(String label, String value) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 100, maxWidth: 200),
      child: RichText(
        text: TextSpan(
          text: "$label: ",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 13,
          ),
          children: [
            TextSpan(
              text: value,
              style: const TextStyle(fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
    );
  }
}
