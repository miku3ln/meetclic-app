import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:latlong2/latlong.dart';
import '../../domain/entities/business.dart';
import 'business_detail_page.dart';
import '../../../shared/utils/deep_link_type.dart';
import 'package:meetclic/shared/localization/app_localizations.dart';
import 'package:meetclic/presentation/widgets/template/custom_app_bar.dart';
import 'package:meetclic/domain/entities/menu_tab_up_item.dart';
import 'package:geolocator/geolocator.dart';
import 'package:meetclic/domain/usecases/get_nearby_businesses_usecase.dart';
import 'package:meetclic/infrastructure/repositories/implementations/business_repository_impl.dart';
import 'package:meetclic/domain/models/business_model.dart';

class MapPosition {
  final double latitude;
  final double longitude;
  final double zoom;

  MapPosition({
    required this.latitude,
    required this.longitude,
    required this.zoom,
  });
}

class BusinessMapPage extends StatefulWidget {
  final DeepLinkInfo? info;
  final List<MenuTabUpItem> itemsStatus;

  const BusinessMapPage({super.key, this.info, required this.itemsStatus});

  @override
  State<BusinessMapPage> createState() => _BusinessMapPageState();
}

class _BusinessMapPageState extends State<BusinessMapPage> {
  final PopupController _popupController = PopupController();
  final MapController _mapController = MapController();
  Map<String, dynamic> currentPosition = {
    'latitude': 0.2322591,
    'longitude': -78.2590913,
    'zoom': 5.0,
  };
  bool isLoading = false;
  List<BusinessModel> businesses = [];
  List<Marker> markers = [];
  Marker? currentLocationMarker;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNearbyBusinesses();
    });
  }

  bool _isGpsEnabled = true;

  Future<void> _checkAndRequestLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    _isGpsEnabled = serviceEnabled; // Guardamos el estado actual

    if (!serviceEnabled) {
      setState(() {}); // Redibujar para actualizar el ícono
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, activa el GPS para continuar.'),
        ),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permiso de ubicación denegado.')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Permiso de ubicación bloqueado permanentemente.'),
        ),
      );
      return;
    }

    // Si se activó durante la solicitud
    setState(() {
      _isGpsEnabled = true;
    });
  }

  Future<void> _loadNearbyBusinesses() async {
    if (isLoading) return;
    setState(() => isLoading = true);

    await _checkAndRequestLocationPermission();
    Position position;
    double latitude = 0;
    double longitude = 0;
    if (_isGpsEnabled) {
      position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      latitude = position.latitude;
      longitude = position.longitude;
    } else {
      latitude = currentPosition["latitude"];
      longitude = currentPosition["longitude"];
    }

    final useCase = GetNearbyBusinessesUseCase(
      repository: BusinessRepositoryImpl(),
    );
    final newCenter = LatLng(latitude, longitude);
    _mapController.move(newCenter, 16);
    final response = await useCase.execute(
      latitude: latitude,
      longitude: longitude,
      radiusKm: 10,
    );

    final businessList = response.data ?? [];

    businesses = businessList;

    _generateMarkers();
    setState(() => isLoading = false);
  }

  void _generateMarkers() {
    markers = businesses.map((business) {
      final markerPoint = LatLng(business.streetLat, business.streetLng);
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

  Future<void> _centerToCurrentLocation() async {
    if (isLoading) return;
    setState(() => isLoading = true);

    await _checkAndRequestLocationPermission();

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final newCenter = LatLng(position.latitude, position.longitude);
      _mapController.move(newCenter, 16);

      currentLocationMarker = Marker(
        point: newCenter,
        width: 60,
        height: 60,
        alignment: Alignment.center,
        child: Image.asset(
          'assets/icons/pututuMarker.png',
        ), // Personaliza aquí tu ícono
      );

      setState(() {});
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo obtener la ubicación actual.'),
        ),
      );
    }

    setState(() => isLoading = false);
  }

  List<Marker> get allMarkers {
    final list = [...markers];
    if (currentLocationMarker != null) {
      list.add(currentLocationMarker!);
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final String title = AppLocalizations.of(
      context,
    ).translate('pages.business');

    return Scaffold(
      appBar: CustomAppBar(title: title, items: widget.itemsStatus),
      body: Stack(
        children: [
          AbsorbPointer(
            absorbing: isLoading,
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                center: LatLng(-0.305, -78.602),
                zoom: 13,
                onTap: (_, __) => _popupController.hideAllPopups(),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.meetclic.meetclic',
                ),
                PopupMarkerLayer(
                  options: PopupMarkerLayerOptions(
                    markers: allMarkers,
                    popupController: _popupController,
                    popupDisplayOptions: PopupDisplayOptions(
                      builder: (context, marker) {
                        final business = businesses.firstWhere(
                          (b) =>
                              b.streetLat == marker.point.latitude &&
                              b.streetLng == marker.point.longitude,
                          orElse: () => businesses.first,
                        );
                        // _mapController.move(marker, _mapController.camera.zoom);
                        return _buildPopupCard(context, business, marker);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: theme.colorScheme.primary,
        onPressed: isLoading ? null : _centerToCurrentLocation,
        tooltip: _isGpsEnabled ? 'Ubicación actual' : 'GPS desactivado',
        child: Icon(
          _isGpsEnabled
              ? Icons.my_location
              : Icons.location_off, // 👈 cambia dinámicamente
        ),
      ),
    );
  }

  Widget _buildPopupCard(BuildContext context, BusinessModel business, marker) {
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
                  business.businessName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Text("Direccion:"+business.street1+" "+business.street2, style: theme.textTheme.bodyMedium),

                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 20),
                    const SizedBox(width: 4),
                    Text(
                          AppLocalizations.of(
                            context,
                          ).translate('gamification.points'),
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
