import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:latlong2/latlong.dart';
import '../../domain/entities/business.dart';
import 'business_detail_page.dart';

class BusinessMapPage extends StatefulWidget {
  const BusinessMapPage({super.key});

  @override
  State<BusinessMapPage> createState() => _BusinessMapPageState();
}

class _BusinessMapPageState extends State<BusinessMapPage> {
  final PopupController _popupController = PopupController();
  final MapController _mapController = MapController();

  final List<Business> businesses = [
    Business(
      id: 1,
      name: 'Muelle Catalina',
      description: 'Pan artesanal y repostería desde 1990.',
      lat: -0.3000,
      lng: -78.6000,
      points: 15,
      imageBackground:  "https://meetclic.com/public/uploads/frontend/templateBySource/1750454099_logo-one.png",
      imageLogo:  "https://meetclic.com/public/uploads/frontend/templateBySource/1750454099_logo-one.png",
starCount: 2.5,
    ),
    Business(
      id: 2,
      name: 'Mikuy Yachack',
      description: 'Venta de productos orgánicos y locales.',
      lat: -0.3100,
      lng: -78.6050,
      points: 20,
      imageBackground:
          "https://meetclic.com/public/uploads/frontend/templateBySource/1750454099_logo-one.png",
      imageLogo:
      "https://meetclic.com/public/uploads/frontend/templateBySource/1750454099_logo-one.png",
      starCount: 3,
    ),
  ];

  late final List<Marker> markers;

  @override
  void initState() {
    super.initState();
    markers = businesses.map((business) {
      final markerPoint = LatLng(business.lat, business.lng);
      return Marker(
        point: markerPoint,
        width: 40,
        height: 40,
        alignment: Alignment.topCenter,
        child: GestureDetector(
          onTap: () {
            _mapController.move(markerPoint, _mapController.camera.zoom);
            _popupController.showPopupsOnlyFor([
              Marker(
                point: markerPoint,
                width: 40,
                height: 40,
                alignment: Alignment.topCenter,
                child: const Icon(
                  Icons.location_on,
                  color: Colors.red,
                  size: 40,
                ),
              ),
            ]);
          },
          child: const Icon(Icons.location_on, color: Colors.red, size: 40),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Empresas'),
        backgroundColor: theme.appBarTheme.backgroundColor,
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          center: LatLng(-0.305, -78.602),
          zoom: 13,
          onTap: (_, __) => _popupController.hideAllPopups(),
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.meetclic.app',
          ),
          PopupMarkerLayer(
            options: PopupMarkerLayerOptions(
              markers: markers,
              popupController: _popupController,
              popupDisplayOptions: PopupDisplayOptions(
                builder: (context, marker) {
                  final business = businesses.firstWhere(
                    (b) =>
                        b.lat == marker.point.latitude &&
                        b.lng == marker.point.longitude,
                    orElse: () => businesses[0],
                  );
                  return _buildPopupCard(context, business);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopupCard(BuildContext context, Business business) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => BusinessDetailPage(business: business),
          ),
        );
      },
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.7,
        child: Card(
          elevation: 6,
          margin: const EdgeInsets.all(8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: theme.colorScheme.surface,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  business.name,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(business.description, style: theme.textTheme.bodyMedium),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      color: theme.colorScheme.secondary,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '+${business.points} puntos',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
