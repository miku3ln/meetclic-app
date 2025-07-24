class BusinessModel {
  final int id;
  final String title;
  final String description;
  final String businessName;
  final String email;
  final String phoneValue;
  final String pageUrl;
  final String street1;
  final String street2;
  final double streetLat;
  final double streetLng;
  final String status;
  final double qualification;
  final int businessSubcategoryId;
  final String subcategoryName;
  final String fiscalPosition;
  final double distance;
  final String distanceKmText;
  final String sourceLogo;

  BusinessModel({
    required this.id,
    required this.title,
    required this.description,
    required this.businessName,
    required this.email,
    required this.phoneValue,
    required this.pageUrl,
    required this.street1,
    required this.street2,
    required this.streetLat,
    required this.streetLng,
    required this.status,
    required this.qualification,
    required this.businessSubcategoryId,
    required this.subcategoryName,
    required this.fiscalPosition,
    required this.distance,
    required this.distanceKmText,
    required this.sourceLogo,

  });

  factory BusinessModel.fromJson(Map<String, dynamic> json) {
    return BusinessModel(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      businessName: json['business_name'] ?? '',
      email: json['email'] ?? '',
      phoneValue: json['phone_value'] ?? '',
      pageUrl: json['page_url'] ?? '',
      street1: json['street_1'] ?? '',
      street2: json['street_2'] ?? '',
      streetLat: double.parse(json['street_lat'].toString()),
      streetLng: double.parse(json['street_lng'].toString()),
      status: json['status'] ?? '',
      qualification: double.tryParse(json['qualification'].toString()) ?? 0.0,
      businessSubcategoryId: json['business_subcategories_id'],
      subcategoryName: json['subcategory_name'] ?? '',
      fiscalPosition: json['fiscal_position'] ?? '',
      distance: double.tryParse(json['distance'].toString()) ?? 0.0,
      distanceKmText: json['distance_km'] ?? '',
      sourceLogo: json['sourceLogo'] ?? '',

    );
  }
}
