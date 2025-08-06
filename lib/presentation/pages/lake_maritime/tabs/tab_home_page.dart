import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../../../../domain/models/maritime_departure_model.dart';
import '../reports/bar_chart_passengers_by_date.dart';
import '../reports/avg_age_line_chart.dart';

import 'package:intl/intl.dart';

Map<String, Map<String, int>> getPassengersByDateAndType(List<MaritimeDepartureModel> data) {
  final Map<String, Map<String, int>> result = {};
  final DateFormat formatter = DateFormat('dd-MM-yyyy'); // Formato: día-mes-año

  for (final departure in data) {
    final DateTime parsedDate = DateTime.parse(departure.arrivalTime);
    final String formattedDate = formatter.format(parsedDate);

    result.putIfAbsent(formattedDate, () => {"ADULT": 0, "CHILD": 0});

    for (final customer in departure.customers ?? []) {
      final type = customer.type.toUpperCase(); // Para estandarizar el valor
      if (type == "ADULT" || type == "CHILD") {
        result[formattedDate]![type] = result[formattedDate]![type]! + 1;
      }
    }
  }

  return result;
}
Map<String, double> getAvgAgeByDate(List<MaritimeDepartureModel> data) {
  final Map<String, List<int>> ageByDate = {};

  for (final departure in data) {
    final date = DateFormat('dd-MM-yyyy')
        .format(DateTime.parse(departure.arrivalTime));
    final ages = departure.customers?.map((c) => c.age).toList() ?? [];
    if (ages.isNotEmpty) {
      ageByDate.putIfAbsent(date, () => []);
      ageByDate[date]!.addAll(ages);
    }
  }

  final Map<String, double> avgByDate = {};
  for (final entry in ageByDate.entries) {
    final ages = entry.value;
    final avg = ages.reduce((a, b) => a + b) / ages.length;
    avgByDate[entry.key] = avg;
  }

  return Map.fromEntries(avgByDate.entries.toList()
    ..sort((a, b) => a.key.compareTo(b.key)));
}

Map<String, Map<String, double>> getAgeStatsByDate(List<MaritimeDepartureModel> data) {
  final Map<String, List<int>> ageByDate = {};
  final DateFormat formatter = DateFormat('dd-MM-yyyy');

  for (final departure in data) {
    final date = formatter.format(DateTime.parse(departure.arrivalTime));
    final ages = departure.customers?.map((c) => c.age).whereType<int>().toList() ?? [];

    if (ages.isNotEmpty) {
      ageByDate.putIfAbsent(date, () => []);
      ageByDate[date]!.addAll(ages);
    }
  }
  final Map<String, Map<String, double>> result = {};
  ageByDate.forEach((date, ages) {
    final total = ages.fold<int>(0, (sum, age) => sum + age);
    final average = total / ages.length;
    result[date] = {"averageAge": average};
  });

  return result;
}
Map<String, int> getPassengersByHourRange(List<MaritimeDepartureModel> data) {
  final Map<String, int> ranges = {"Mañana": 0, "Tarde": 0, "Noche": 0};

  for (final departure in data) {
    final hour = int.parse(departure.arrivalTime.split("T")[1].substring(0, 2));
    final count = departure.customers?.length ?? 0;

    if (hour >= 6 && hour < 12) {
      ranges["Mañana"] = ranges["Mañana"]! + count;
    } else if (hour >= 12 && hour < 18) {
      ranges["Tarde"] = ranges["Tarde"]! + count;
    } else {
      ranges["Noche"] = ranges["Noche"]! + count;
    }
  }

  return ranges;
}
Map<String, int> getTopPassengers(List<MaritimeDepartureModel> data) {
  final Map<String, int> freq = {};

  for (final departure in data) {
    for (final customer in departure.customers ?? []) {
      freq[customer.documentNumber] =
          (freq[customer.documentNumber] ?? 0) + 1;
    }
  }

  final sorted = freq.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  return Map.fromEntries(sorted.take(5)); // Top 5
}
Map<String, Map<String, double>> getPercentageByDate(List<MaritimeDepartureModel> data) {
  final Map<String, Map<String, int>> raw = getPassengersByDateAndType(data);
  final Map<String, Map<String, double>> result = {};

  for (final entry in raw.entries) {
    final total = (entry.value["ADULT"]! + entry.value["CHILD"]!).toDouble();
    if (total == 0) continue;

    result[entry.key] = {
      "ADULT": (entry.value["ADULT"]! / total) * 100,
      "CHILD": (entry.value["CHILD"]! / total) * 100,
    };
  }

  return result;
}
Future<List<MaritimeDepartureModel>> _loadAndProcessData() async {
  final jsonString =
  await rootBundle.loadString('assets/data/maritime_departures_data.json');
  final List<dynamic> jsonList = jsonDecode(jsonString);

  final List<MaritimeDepartureModel> departures = jsonList
      .map((e) => MaritimeDepartureModel.fromJson(e))
      .toList();
  departures.sort((a, b) => a.arrivalTime.compareTo(b.arrivalTime));

  return departures;
}
class TabHomePage extends StatefulWidget {
  const TabHomePage({super.key});

  @override
  State<TabHomePage> createState() => _TabHomePageState();
}
class _TabHomePageState extends State<TabHomePage> {
  Map<String, Map<String, int>> passengersData = {};
  late Map<String, double> avgAgeData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await _loadAndProcessData();
    final chartData = getPassengersByDateAndType(data);
    final processed = getAvgAgeByDate(data);

    setState(() {
      passengersData = chartData;
      avgAgeData = processed;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView( // 👈 ESTE
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Pasajeros por Fecha (Niños vs Adultos)", style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(
            height: 300,
            child: PassengerBarChart(dataByDate: passengersData),
          ),
          const SizedBox(height: 24),
          const Text("Edad Promedio por Fecha", style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(
            height: 300,
            child: AvgAgeLineChart(dataByDate: avgAgeData),
          ),
        ],
      ),
    );
  }
}
