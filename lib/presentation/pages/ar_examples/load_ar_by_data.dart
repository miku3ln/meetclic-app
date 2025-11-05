import 'dart:math' as math;

import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';
import 'package:ar_flutter_plugin/datatypes/config_planedetection.dart';
import 'package:ar_flutter_plugin/datatypes/node_types.dart';
import 'package:ar_flutter_plugin/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin/models/ar_node.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vmath;

// ---- items_sources.dart (igual) ----
class ItemPosition {
  final double lat;
  final double lng;

  const ItemPosition({required this.lat, required this.lng});
}

class ItemSources {
  final String glb;
  final String img;

  const ItemSources({required this.glb, required this.img});
}

class ItemAR {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final ItemPosition position;
  final ItemSources sources;

  const ItemAR({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.position,
    required this.sources,
  });
}

final List<ItemAR> itemsSources = [
  ItemAR(
    id: "taita",
    title: "Taita Imbabura – El Abuelo que todo lo ve",
    subtitle: "Ñawi Hatun Yaya",
    description: "Sabio y protector, guardián del viento.",
    position: ItemPosition(lat: 0.20477, lng: -78.20639),
    sources: ItemSources(
      glb: "assets/muelle-catalina/taita-imbabura-toon-1.glb",
      img: "assets/muelle-catalina/images/taita-imbabura.png",
    ),
  ),
  ItemAR(
    id: "cerro-cusin",
    title: "Cusin – El guardián del paso fértil",
    subtitle: "Allpa ñampi rikchar",
    description: "Alegre y trabajador, cuida las chacras.",
    position: ItemPosition(lat: 0.20435, lng: -78.20688),
    sources: ItemSources(
      glb: "assets/muelle-catalina/cusin.glb",
      img: "assets/muelle-catalina/images/elcusin.png",
    ),
  ),
  ItemAR(
    id: "mojanda",
    title: "Mojanda – El susurro del páramo",
    subtitle: "Sachayaku mama",
    description: "Entre neblinas y lagunas, hilos de agua fría que renuevan.",
    position: ItemPosition(lat: 0.20401, lng: -78.20723),
    sources: ItemSources(
      glb: "assets/muelle-catalina/taita-imbabura-otro.glb",
      img: "assets/muelle-catalina/images/mojanda.png",
    ),
  ),
  ItemAR(
    id: "mama-cotacachi",
    title: "Mama Cotacachi – Madre de la Pachamama",
    subtitle: "Allpa mama- Warmi Rasu",
    description: "Dulce y poderosa, cuida los ciclos de la vida.",
    position: ItemPosition(lat: 0.20369, lng: -78.20759),
    sources: ItemSources(
      glb: "assets/muelle-catalina/mama-cotacachi.glb",
      img: "assets/muelle-catalina/images/warmi-razu.png",
    ),
  ),
  ItemAR(
    id: "coraza",
    title: "El Coraza – Espíritu de la celebración",
    subtitle: "Kawsay Taki",
    description: "Orgullo y dignidad; su danza es memoria viva de lucha.",
    position: ItemPosition(lat: 0.20349, lng: -78.20779),
    sources: ItemSources(
      glb: "assets/muelle-catalina/coraza-one.glb",
      img: "assets/muelle-catalina/images/elcoraza.png",
    ),
  ),
  ItemAR(
    id: "lechero",
    title: "El Lechero – Árbol del Encuentro y los Deseos",
    subtitle: "Kawsay ranti",
    description: "Testigo de promesas, desde sus ramas el mundo sueña.",
    position: ItemPosition(lat: 0.20316, lng: -78.20790),
    sources: ItemSources(
      glb: "assets/muelle-catalina/other.glb",
      img: "assets/muelle-catalina/images/lechero.png",
    ),
  ),
  ItemAR(
    id: "lago-san-pablo",
    title: "Yaku Mama – La Laguna Viva",
    subtitle: "Yaku Mama – Kawsaycocha",
    description: "Aquí termina el camino y comienza la conexión profunda.",
    position: ItemPosition(lat: 0.20284, lng: -78.20802),
    sources: ItemSources(
      glb: "assets/muelle-catalina/lago-san-pablo.glb",
      img: "assets/muelle-catalina/images/yaku-mama.png",
    ),
  ),
];

// ---- Widget principal ----
class LoadArByData extends StatefulWidget {
  final bool isLocal;

  const LoadArByData({super.key, required this.isLocal});

  @override
  State<LoadArByData> createState() => _LoadArByDataState();
}

class _LoadArByDataState extends State<LoadArByData> {
  ARSessionManager? _sessionManager;
  ARObjectManager? _objectManager;

  ItemAR? _selected;
  ARNode? _currentNode;

  static const double kPlaceDistanceMeters = 1.6;
  final vmath.Vector3 _defaultScale = vmath.Vector3.all(0.8);

  @override
  void initState() {
    super.initState();
    _selected = itemsSources.first;
  }

  @override
  void dispose() {
    // _objectManager?.dispose(); // no existe en algunas versiones
    _sessionManager?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            _buildARView(),
            _buildTopBar(context),
            _buildBottomBar(context),
            _buildReticleOverlay(),
            _buildPlaceButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildARView() {
    return ARView(
      onARViewCreated: _onARViewCreated,
      planeDetectionConfig: PlaneDetectionConfig.none,
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        margin: const EdgeInsets.only(top: 8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.35),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonHideUnderline(
              child: DropdownButton<ItemAR>(
                dropdownColor: const Color(0xFF1E1E1E),
                value: _selected,
                items: itemsSources.map((e) {
                  return DropdownMenuItem(
                    value: e,
                    child: Text(
                      e.title,
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() => _selected = val);
                  _showSnack("Seleccionado: ${val?.id}");
                },
              ),
            ),
            const SizedBox(width: 12),
            Row(
              children: [
                const Text("Local", style: TextStyle(color: Colors.white)),
                Switch(
                  value: widget.isLocal,
                  onChanged: (_) {
                    _alert(
                      "isLocal es un parámetro del widget",
                      "Pásalo al crear LoadArByData(isLocal: ...).",
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    final sel = _selected;
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.35),
          borderRadius: BorderRadius.circular(12),
        ),
        child: SizedBox(
          width: MediaQuery.sizeOf(context).width * 0.94,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                sel?.title ?? "",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                sel?.subtitle ?? "",
                style: const TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                sel?.description ?? "",
                style: const TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  _smallBtn(
                    icon: Icons.delete_forever,
                    label: "Quitar modelo",
                    onTap: () async {
                      await _removeCurrentNode();
                      _alert("Acción", "Modelo eliminado.");
                    },
                  ),
                  _smallBtn(
                    icon: Icons.center_focus_strong,
                    label: "Recolocar",
                    onTap: _placeAtReticle,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _smallBtn({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2A2A2A),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildReticleOverlay() {
    return IgnorePointer(
      ignoring: true,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Transform.rotate(
              angle: -math.pi / 2,
              child: Icon(Icons.navigation, size: 36, color: Colors.white70),
            ),
            const SizedBox(height: 6),
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white70, width: 2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceButton() {
    return Positioned(
      bottom: 120,
      right: 16,
      child: FloatingActionButton.extended(
        onPressed: _placeAtReticle,
        icon: const Icon(Icons.add_location_alt),
        label: const Text("Colocar aquí"),
      ),
    );
  }

  // ---------------- AR setup & helpers ----------------

  Future<void> _onARViewCreated(
    ARSessionManager sessionManager,
    ARObjectManager objectManager,
    ARAnchorManager anchorManager,
    ARLocationManager locationManager,
  ) async {
    _sessionManager = sessionManager;
    _objectManager = objectManager;

    // Habilita gestos desde el SessionManager
    await _sessionManager?.onInitialize(
      showFeaturePoints: false,
      showPlanes: false,
      showWorldOrigin: false,
      handleTaps: false,
      // taps de plano (no de nodo)
      handlePans: true,
      // <- gestos de arrastre
      handleRotation: true, // <- gestos de rotación
    );

    // onInitialize del ObjectManager ya NO recibe parámetros
    await _objectManager?.onInitialize();

    // Taps sobre nodos (lista de ids de nodos tocados)
    _objectManager?.onNodeTap = (nodes) {
      if (_currentNode != null && nodes.contains(_currentNode!.name)) {
        _alert("Evento", "Tap en el modelo (${_selected?.id ?? '-'})");
      }
    };

    // Gestos de arrastre
    _objectManager?.onPanStart = (node) =>
        _showSnack('Arrastre iniciado: $node');
    _objectManager?.onPanChange = (node) => _showSnack('Arrastrando: $node');
    _objectManager?.onPanEnd = (nodeName, newTransform) {
      // newTransform es un vmath.Matrix4 con la pose final
      _showSnack('Arrastre terminó: $nodeName');
    };

    // Gestos de rotación
    _objectManager?.onRotationStart = (node) =>
        _showSnack('Rotación inicio: $node');
    _objectManager?.onRotationChange = (node) => _showSnack('Rotando: $node');
    _objectManager?.onRotationEnd = (nodeName, newTransform) {
      _showSnack('Rotación terminó: $nodeName');
    };

    _showSnack("Cámara lista. Apunta con la flecha y toca 'Colocar aquí'.");
  }

  ARNode _buildNodeFor(ItemAR item) {
    final isLocal = widget.isLocal;
    return ARNode(
      type: isLocal ? NodeType.localGLB : NodeType.webGLB,
      uri: item.sources.glb,
      scale: _defaultScale,
      position: vmath.Vector3.zero(),
      rotation: vmath.Vector4(0, 1, 0, 0),
    );
  }

  Future<void> _removeCurrentNode() async {
    if (_currentNode != null) {
      await _objectManager?.removeNode(_currentNode!);
      _currentNode = null;
    }
  }

  Future<void> _placeAtReticle() async {
    if (_sessionManager == null || _objectManager == null) return;
    if (_selected == null) return;

    await _removeCurrentNode();

    final node = _buildNodeFor(_selected!);

    // Si tu versión soporta getCameraPose:
    final cameraPose = await _sessionManager!.getCameraPose();
    vmath.Vector3 placePosition;

    if (cameraPose != null) {
      final m = cameraPose;
      final forward = vmath.Vector3(
        -m.entry(0, 2),
        -m.entry(1, 2),
        -m.entry(2, 2),
      );
      final camPos = vmath.Vector3(m.entry(0, 3), m.entry(1, 3), m.entry(2, 3));
      placePosition = camPos + forward.normalized() * kPlaceDistanceMeters;
    } else {
      // Fallback: delante del origen de cámara
      placePosition = vmath.Vector3(0, 0, -kPlaceDistanceMeters);
      _showSnack("No se obtuvo pose de cámara; usando fallback.");
    }

    node.position = placePosition;

    final added = await _objectManager!.addNode(node);
    if (added != true) {
      _alert("Error", "No se pudo agregar el modelo a la escena.");
      return;
    }
    _currentNode = node;

    _alert(
      "Colocado",
      "Modelo '${_selected!.id}' ubicado a ${kPlaceDistanceMeters} m.",
    );
  }

  // ---------------- UI helpers ----------------

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(milliseconds: 900)),
    );
  }

  Future<void> _alert(String title, String msg) async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(msg),
        actions: [
          TextButton(
            child: const Text("OK"),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
