/*import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';
import 'package:ar_flutter_plugin/datatypes/config_planedetection.dart'; // PlaneDetectionConfig
import 'package:ar_flutter_plugin/datatypes/node_types.dart'; // <-- NodeType aquí
import 'package:ar_flutter_plugin/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin/models/ar_node.dart';*/

/*
class ARCapturePage extends StatefulWidget {
  final String
  glbAssetPath; // p.ej. assets/totems/sembrador/totem_sembrador.glb
  const ARCapturePage({super.key, required this.glbAssetPath});

  @override
  State<ARCapturePage> createState() => _ARCapturePageState();
}

class _ARCapturePageState extends State<ARCapturePage> {
  ARSessionManager? _session;
  ARObjectManager? _objects;
  ARNode? _node;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ARView(
        // En 0.7.3 se configura la detección de planos desde el constructor:
        planeDetectionConfig:
            PlaneDetectionConfig.horizontal, // o .horizontalAndVertical
        onARViewCreated: _onARViewCreated, // firma de 4 parámetros
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_node != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Tótem invocado y guardado ✨')),
            );
            Navigator.pop(context);
          }
        },
        icon: const Icon(Icons.check),
        label: const Text('Invocar'),
      ),
    );
  }

  // Firma correcta para 0.7.3:
  // ARViewCreatedCallback = void Function(
  //   ARSessionManager, ARObjectManager, ARAnchorManager, ARLocationManager)
  Future<void> _onARViewCreated(
    ARSessionManager sessionManager,
    ARObjectManager objectManager,
    ARAnchorManager anchorManager,
    ARLocationManager locationManager,
  ) async {
    _session = sessionManager;
    _objects = objectManager;

    // Tap en plano o punto -> colocar GLB
    _session!.onPlaneOrPointTap = (hits) async {
      if (hits.isEmpty) return;
      final hit = hits.first;

      final node = ARNode(
        type: NodeType.localGLTF2,
        uri: widget.glbAssetPath,
        position: hit.worldTransform.getTranslation(),
        rotation: v.Vector4(0, 1, 0, 0),
        scale: v.Vector3(
          1.0,
          1.0,
          1.0,
        ), // tu GLB debe venir ya a escala en metros
      );

      final added = await _objects!.addNode(node); // devuelve bool?
      if (added == true) {
        _node = node;
        setState(() {});
      }
    };
  }
}
*/
class Totem {
  final String id;
  final String nameEs;
  final String nameKi;
  final double lat;
  final double lng;
  final double captureRadius; // metros
  final String assetPng; // ícono o preview 2D
  final String assetGlb; // ruta local o url remota
  final String loreShort;
  final String loreQrUrl;
  final bool isLocal; // true = assets/, false = url

  const Totem({
    required this.id,
    required this.nameEs,
    required this.nameKi,
    required this.lat,
    required this.lng,
    required this.captureRadius,
    required this.assetPng,
    required this.assetGlb,
    required this.loreShort,
    required this.loreQrUrl,
    required this.isLocal,
  });

  factory Totem.fromJson(Map<String, dynamic> j) => Totem(
    id: j['id'],
    nameEs: j['name_es'],
    nameKi: j['name_ki'],
    lat: (j['lat'] as num).toDouble(),
    lng: (j['lng'] as num).toDouble(),
    captureRadius: (j['capture_radius'] as num).toDouble(),
    assetPng: j['asset_png'],
    assetGlb: j['asset_glb'],
    loreShort: j['lore_short'],
    loreQrUrl: j['lore_qr_url'],
    isLocal: j['is_local'] ?? true, // por defecto local
  );
}

final List<Totem> totems = [
  Totem(
    id: "totem_imbabura",
    nameEs: "Taita Imbabura – El Abuelo que todo lo ve",
    nameKi: "Ñawi Hatun Yaya",
    lat: -0.3495,
    lng: -78.1220,
    captureRadius: 50,
    assetPng: "assets/totems/imbabura/icon.png",
    assetGlb: "assets/totems/imbabura/model.glb",
    loreShort: "Sabio y protector, guardián del viento y los ciclos.",
    loreQrUrl: "https://tu-sitio/qr/imbabura",
    isLocal: true,
  ),
  Totem(
    id: "totem_cotacachi",
    nameEs: "Mama Cotacachi – La Madre Montaña",
    nameKi: "Mama Qutakachi",
    lat: -0.3050,
    lng: -78.2640,
    captureRadius: 50,
    assetPng: "assets/totems/cotacachi/icon.png",
    assetGlb:
        "https://mi-bucket.s3.amazonaws.com/models/cotacachi.glb", // remoto
    loreShort: "Madre sabia que protege los valles y lagunas.",
    loreQrUrl: "https://tu-sitio/qr/cotacachi",
    isLocal: true,
  ),
];
