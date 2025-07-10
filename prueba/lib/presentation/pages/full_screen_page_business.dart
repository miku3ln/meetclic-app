import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class FullScreenPageBusiness extends StatefulWidget {
  const FullScreenPageBusiness({super.key});

  @override
  State<FullScreenPageBusiness> createState() => _FullScreenPageBusinessState();
}

class _FullScreenPageBusinessState extends State<FullScreenPageBusiness> {
  final MapController _mapController = MapController();
  double _zoom = 8.0;

  final LatLng _center = const LatLng(-0.2500, -78.5833); // Cotacachi

  void _zoomIn() {
    setState(() => _zoom += 1);
    _mapController.move(_center, _zoom);
  }

  void _zoomOut() {
    setState(() => _zoom -= 1);
    _mapController.move(_center, _zoom);
  }

  void _openWhatsApp() async {
    final uri = Uri.parse('https://wa.me/593999999999'); // Reemplaza con número real
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se puede abrir WhatsApp')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Empresas'),
        backgroundColor: theme.colorScheme.background,
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: _center,
              zoom: _zoom,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
                userAgentPackageName: 'com.ejemplo.miapp',
              ),
            ],
          ),

          // Botón expandir
          Positioned(
            bottom: 115,
            right: 16,
            child: FloatingActionButton(
              heroTag: 'expand',
              mini: true,
              backgroundColor: theme.colorScheme.surface,
              onPressed: () {},
              child: const Icon(Icons.open_in_full),
            ),
          ),

          // Zoom
          Positioned(
            right: 16,
            top: 100,
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: 'zoom_in',
                  mini: true,
                  backgroundColor: Colors.yellow.shade600,
                  onPressed: _zoomIn,
                  child: const Icon(Icons.add, color: Colors.white),
                ),
                const SizedBox(height: 10),
                FloatingActionButton(
                  heroTag: 'zoom_out',
                  mini: true,
                  backgroundColor: Colors.yellow.shade600,
                  onPressed: _zoomOut,
                  child: const Icon(Icons.remove, color: Colors.white),
                ),
              ],
            ),
          ),

          // Clúster o marcador fijo
          Positioned(
            top: 180,
            left: MediaQuery.of(context).size.width / 2 - 30,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Colors.amber,
                shape: BoxShape.circle,
              ),
              child: const Text('3', style: TextStyle(fontSize: 16)),
            ),
          ),

          // Botones inferiores
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: const Text('Anterior'),
                ),
                ElevatedButton(
                  onPressed: _openWhatsApp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(12),
                  ),
                  child: const Icon(Icons.whatshot, color: Colors.green),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: const Text('Siguiente'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
