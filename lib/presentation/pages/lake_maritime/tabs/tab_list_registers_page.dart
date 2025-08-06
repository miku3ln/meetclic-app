import 'package:flutter/material.dart';
import '../../../../domain/models/maritime_departure_model.dart';
import '../../../../domain/models/customer_model.dart';


class TabListRegistersPage extends StatefulWidget {
  const TabListRegistersPage({super.key});

  @override
  State<TabListRegistersPage> createState() => _TabListRegistersPageState();
}

class _TabListRegistersPageState extends State<TabListRegistersPage> {
  final ScrollController _scrollController = ScrollController();
  final List<MaritimeDepartureModel> _items = [];
  int _page = 1;
  bool _isLoading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _fetchData();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200 &&
          !_isLoading &&
          _hasMore) {
        _fetchData();
      }
    });
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });

    // Simula una llamada al backend con datos reales
    await Future.delayed(const Duration(seconds: 1));

    List<MaritimeDepartureModel> newItems = List.generate(10, (i) {
      return MaritimeDepartureModel(
        businessId: 1,
        userId: 999,
        userManagementId: 5,
        arrivalTime: "2025-08-06 10:00:00",
        responsibleName: "Alex Alba ${(_page - 1) * 10 + i + 1}",
        customers: [
          CustomerModel(
            fullName: "Cliente A",
            documentNumber: "0102030405",
            type: "ADULT",
            age: 30,
          ),
          CustomerModel(
            fullName: "Cliente B",
            documentNumber: "0912345678",
            type: "CHILDREN",
            age: 28,
          ),
        ],
      );
    });

    setState(() {
      _items.addAll(newItems);
      _page++;
      _isLoading = false;
      if (newItems.isEmpty) {
        _hasMore = false;
      }
    });
  }

  Future<void> _refreshList() async {
    setState(() {
      _items.clear();
      _page = 1;
      _hasMore = true;
    });

    await _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshList,
      child: ListView.builder(
        controller: _scrollController,
        itemCount: _items.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index < _items.length) {
            final item = _items[index];
            return ExpansionTile(
              leading: const Icon(Icons.directions_boat),
              title: Text(item.responsibleName),
              subtitle: Text("Hora: ${item.arrivalTime}"),
              trailing: const Icon(Icons.expand_more),
              children: item.customers!.map((customer) {
                return ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: Text(customer.fullName),
                  subtitle: Text("Cédula: ${customer.documentNumber}"),
                  trailing: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text("Edad: ${customer.age}"),
                      Text("Tipo: ${customer.type}"),
                    ],
                  ),
                );
              }).toList(),
            );
          } else {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: CircularProgressIndicator()),
            );
          }
        },
      ),
    );
  }
}
