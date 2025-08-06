import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../domain/models/customer_model.dart';
import '../config/server_config.dart';

class MaritimeDepartureResult {
  final bool success;
  final String message;
  final List data;

  MaritimeDepartureResult({
    required this.success,
    required this.message,
    required this.data,
  });

  factory MaritimeDepartureResult.fromJson(Map<String, dynamic> json) {
    return MaritimeDepartureResult(
      success: json['success'],
      message: json['message'],
      data: json['data'],
    );
  }

  factory MaritimeDepartureResult.empty() {
    return MaritimeDepartureResult(
      success: false,
      message: 'No existe Información!',
      data: [],
    );
  }
}

Map<String, String> splitFullName(String fullName) {
  final parts = fullName.trim().split(RegExp(r'\s+')); // Divide por espacios

  if (parts.length >= 4) {
    return {
      'last_name': '${parts[0]} ${parts[1]}',
      'name': '${parts[2]} ${parts[3]}'
    };
  } else if (parts.length == 3) {
    return {
      'last_name': '${parts[0]} ${parts[1]}',
      'name': parts[2]
    };
  } else if (parts.length == 2) {
    return {
      'last_name': parts[0],
      'name': parts[1]
    };
  } else {
    return {
      'last_name': fullName,
      'name': fullName
    };
  }
}

class MaritimeDepartureService {
  final String baseUrl = '${ServerConfig.baseUrl}';

  Map<String, dynamic> buildMaritimeDeparturePayloadObject(
      List<CustomerModel> customers) {
    final departureData = {
      "business_id": 1,
      "user_id": 999,
      "user_management_id": 5,
      "arrival_time": "2025-08-06 10:00:00",
      "responsible_name": "Alex Alba"
    };

    final customersData = customers.map((c) {
      final nameParts = splitFullName(c.fullName);
      return {
        "full_name": c.fullName,
        "last_name": nameParts['last_name'],
        "name": nameParts['name'],
        "type": c.type == 'A' ? 'ADULT' : "CHILD",
        //"type": c.type,
        "age": c.age,
        "document_number": c.documentNumber,
      };
    }).toList();

    return {
      "data": {
        "MaritimeDepartures": departureData,
        "Customers": customersData
      }
    };
  }

  Map<String, dynamic> buildMaritimeDeparturePayloadString(
      List<CustomerModel> customers) {
    final departureData = {
      "business_id": 1,
      "user_id": 1,
      "arrival_time": "2025-08-06 10:00:00",
      "responsible_name": "Alex Alba"
    };

    final customersData = customers.map((c) {
      final nameParts = splitFullName(c.fullName);
      return {
        "full_name": c.fullName,
        "last_name": nameParts['last_name'],
        "name": nameParts['name'],
        "type": c.type,
        "age": c.age,
        "document_number": c.documentNumber,

      };
    }).toList();

    return {
      "data": jsonEncode({
        "MaritimeDepartures": departureData,
        "Customers": customersData
      })
    };
  }

  Future<MaritimeDepartureResult> sendMaritimeDeparture(
      Map<String, dynamic> payload) async {
    final uri = Uri.parse('$baseUrl/saveMaritimeDepartureApi');

    final response = await http.post(
      uri,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: json.encode(payload),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      return MaritimeDepartureResult.fromJson(jsonData);
    } else {
      return MaritimeDepartureResult.empty();
    }
  }
}

class SendMaritimeDepartureUseCase {
  final MaritimeDepartureService apiService;

  SendMaritimeDepartureUseCase(this.apiService);

  Future<SendMaritimeViewModel> execute(Map<String, dynamic> payload) async {
    final response = await apiService.sendMaritimeDeparture(payload);
    return MaritimeDepartureMapper.toViewModel(response);
  }
}

class SendMaritimeViewModel {


  final bool success;
  final String message;

  SendMaritimeViewModel({
    required this.success,
    required this.message,

  });
}

class MaritimeDepartureMapper {
  static SendMaritimeViewModel toViewModel(MaritimeDepartureResult response) {
    return SendMaritimeViewModel(
      success: response.success,
      message: response.message,
    );
  }
}