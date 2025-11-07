import 'dart:convert';

import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';
import 'package:ar_flutter_plugin/datatypes/config_planedetection.dart';
import 'package:ar_flutter_plugin/datatypes/node_types.dart';
import 'package:ar_flutter_plugin/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin/models/ar_node.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:vector_math/vector_math_64.dart' as vmath;

/// ------------------ MODELOS ------------------
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

/// ------------------ DATA (paths reales) ------------------
final List<ItemAR> itemsSources = [
  ItemAR(
    id: "taita",
    title: "Taita Imbabura – El Abuelo que todo lo ve",
    subtitle: "Ñawi Hatun Yaya",
    description: "Sabio y protector, guardián del viento.",
    position: ItemPosition(lat: 0.20477, lng: -78.20639),
    sources: ItemSources(
      glb: "assets/totems/muelle-catalina/taita-imbabura-toon-1.glb",
      img: "assets/totems/muelle-catalina/images/taita-imbabura.png",
    ),
  ),
  ItemAR(
    id: "cerro-cusin",
    title: "Cusin – El guardián del paso fértil",
    subtitle: "Allpa ñampi rikchar",
    description: "Alegre y trabajador, cuida las chacras.",
    position: ItemPosition(lat: 0.20435, lng: -78.20688),
    sources: ItemSources(
      glb: "assets/totems/muelle-catalina/cusin.glb",
      img: "assets/totems/muelle-catalina/images/elcusin.png",
    ),
  ),
  ItemAR(
    id: "mojanda",
    title: "Mojanda – El susurro del páramo",
    subtitle: "Sachayaku mama",
    description: "Entre neblinas y lagunas, hilos de agua fría que renuevan.",
    position: ItemPosition(lat: 0.20401, lng: -78.20723),
    sources: ItemSources(
      glb: "assets/totems/muelle-catalina/taita-imbabura-otro.glb",
      img: "assets/totems/muelle-catalina/images/mojanda.png",
    ),
  ),
  ItemAR(
    id: "mama-cotacachi",
    title: "Mama Cotacachi – Madre de la Pachamama",
    subtitle: "Allpa mama- Warmi Rasu",
    description: "Dulce y poderosa, cuida los ciclos de la vida.",
    position: ItemPosition(lat: 0.20369, lng: -78.20759),
    sources: ItemSources(
      glb: "assets/totems/muelle-catalina/mama-cotacachi.glb",
      img: "assets/totems/muelle-catalina/images/warmi-razu.png",
    ),
  ),
  ItemAR(
    id: "coraza",
    title: "El Coraza – Espíritu de la celebración",
    subtitle: "Kawsay Taki",
    description: "Orgullo y dignidad; su danza es memoria viva de lucha.",
    position: ItemPosition(lat: 0.20349, lng: -78.20779),
    sources: ItemSources(
      glb: "assets/totems/muelle-catalina/coraza-one.glb",
      img: "assets/totems/muelle-catalina/images/elcoraza.png",
    ),
  ),
  ItemAR(
    id: "lechero",
    title: "El Lechero – Árbol del Encuentro y los Deseos",
    subtitle: "Kawsay ranti",
    description: "Testigo de promesas, desde sus ramas el mundo sueña.",
    position: ItemPosition(lat: 0.20316, lng: -78.20790),
    sources: ItemSources(
      glb: "assets/totems/muelle-catalina/other.glb",
      img: "assets/totems/muelle-catalina/images/lechero.png",
    ),
  ),
  ItemAR(
    id: "lago-san-pablo",
    title: "Yaku Mama – La Laguna Viva",
    subtitle: "Yaku Mama – Kawsaycocha",
    description: "Aquí termina el camino y comienza la conexión profunda.",
    position: ItemPosition(lat: 0.20284, lng: -78.20802),
    sources: ItemSources(
      glb: "assets/totems/muelle-catalina/lago-san-pablo.glb",
      img: "assets/totems/muelle-catalina/images/yaku-mama.png",
    ),
  ),
];

/// ------------------ WIDGET ------------------
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

  // Retícula ON hasta que se coloque el modelo
  bool _showReticle = true;

  // Descubrimiento de GLBs via AssetManifest
  List<String> _availableGlbs = [];
  String? _selectedGlbFromManifest; // si se selecciona, tiene prioridad

  static const double kPlaceDistanceMeters = 1.6;
  final vmath.Vector3 _defaultScale = vmath.Vector3.all(0.8);

  @override
  void initState() {
    super.initState();
    _selected = itemsSources.first;
    _loadGlbsFromManifest();
  }

  Future<void> _loadGlbsFromManifest() async {
    try {
      final manifest = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> map = json.decode(manifest);
      final base = 'assets/totems/muelle-catalina/';
      final glbs =
          map.keys
              .where(
                (k) => k.startsWith(base) && k.toLowerCase().endsWith('.glb'),
              )
              .toList()
            ..sort();
      setState(() {
        _availableGlbs = glbs;
      });
    } catch (e) {
      debugPrint('No se pudo leer AssetManifest.json: $e');
      // No bloquea la app; solo no habrá dropdown de diagnóstico
    }
  }

  @override
  void dispose() {
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
      planeDetectionConfig: PlaneDetectionConfig.none, // sin hit-test ni mano
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        margin: const EdgeInsets.only(top: 8, left: 8, right: 8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.35),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Dropdown principal (items AR)
            Expanded(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<ItemAR>(
                  isExpanded: true,
                  dropdownColor: const Color(0xFF1E1E1E),
                  value: _selected,
                  items: itemsSources.map((e) {
                    return DropdownMenuItem(
                      value: e,
                      child: Text(
                        e.title,
                        style: const TextStyle(color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (val) async {
                    setState(() {
                      _selected = val;
                      _selectedGlbFromManifest =
                          null; // vuelve a usar el del item
                    });
                    await _resetPlacement();
                    _showSnack("Seleccionado: ${val?.id}");
                  },
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Dropdown diagnóstico (GLBs desde manifest)
            if (_availableGlbs.isNotEmpty)
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    dropdownColor: const Color(0xFF1E1E1E),
                    hint: const Text(
                      'GLB (diagnóstico)',
                      style: TextStyle(color: Colors.white70),
                    ),
                    value: _selectedGlbFromManifest,
                    items: _availableGlbs
                        .map(
                          (p) => DropdownMenuItem(
                            value: p,
                            child: Text(
                              p.split('/').last,
                              style: const TextStyle(color: Colors.white),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (val) async {
                      setState(() => _selectedGlbFromManifest = val);
                      await _resetPlacement();
                      _showSnack("GLB: ${val?.split('/').last}");
                    },
                  ),
                ),
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
                      await _resetPlacement();
                      _alert("Acción", "Modelo eliminado. Retícula activa.");
                    },
                  ),
                  _smallBtn(
                    icon: Icons.center_focus_strong,
                    label: "Recolocar",
                    onTap: () async {
                      await _resetPlacement();
                      _showSnack("Apunta y toca 'Colocar aquí'");
                    },
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

  /// Retícula (sin mano)
  Widget _buildReticleOverlay() {
    if (!_showReticle) return const SizedBox.shrink();
    return IgnorePointer(
      ignoring: true,
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white70, width: 2),
              ),
            ),
            Container(width: 2, height: 36, color: Colors.white70),
            Container(width: 36, height: 2, color: Colors.white70),
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

  /// ------------------ AR setup ------------------
  Future<void> _onARViewCreated(
    ARSessionManager sessionManager,
    ARObjectManager objectManager,
    ARAnchorManager anchorManager,
    ARLocationManager locationManager,
  ) async {
    _sessionManager = sessionManager;
    _objectManager = objectManager;

    try {
      await _sessionManager?.onInitialize(
        showFeaturePoints: false,
        showPlanes: false,
        showWorldOrigin: false,
        handleTaps: false,
        handlePans: true,
        handleRotation: true,
      );

      // Captura errores nativos del motor AR

      await _objectManager?.onInitialize();

      _objectManager?.onNodeTap = (nodes) {
        if (_currentNode != null && nodes.contains(_currentNode!.name)) {
          _alert("Evento", "Tap en el modelo (${_selected?.id ?? '-'})");
        }
      };

      _showSnack("Cámara lista. Sin hit-test; usa la retícula central.");
    } catch (e, st) {
      debugPrint("Error iniciando sesión AR: $e\n$st");
      _alert("Error al iniciar AR", "$e");
    }
  }

  /// Construye el nodo. Si hay GLB seleccionado en el dropdown de diagnóstico,
  /// se usa ese; caso contrario, el del item seleccionado.
  ARNode _buildNode() {
    final isLocal = widget.isLocal;
    final glbPath = _selectedGlbFromManifest ?? _selected!.sources.glb;

    final uriForNode = isLocal
        ? glbPath.replaceFirst('assets/', '') // NodeType.localGLB sin 'assets/'
        : glbPath;

    return ARNode(
      type: isLocal ? NodeType.localGLB : NodeType.webGLB,
      uri: uriForNode,
      scale: _defaultScale,
      position: vmath.Vector3.zero(),
      rotation: vmath.Vector4(0, 1, 0, 0),
    );
  }

  /// Reintenta addNode por si el tracking aún no está estable
  Future<bool> _tryAddNodeWithRetry(ARNode node, {int maxRetries = 3}) async {
    for (int i = 0; i < maxRetries; i++) {
      final ok = await _objectManager!.addNode(node);
      if (ok == true) return true;
      await Future.delayed(Duration(milliseconds: 350 * (i + 1)));
    }
    return false;
  }

  /// ------------------ Colocar modelo ------------------
  Future<void> _placeAtReticle() async {
    if (_sessionManager == null || _objectManager == null) return;
    if (_selected == null) return;

    await _removeCurrentNode();

    final isLocal = widget.isLocal;
    final glbPath = _selectedGlbFromManifest ?? _selected!.sources.glb;
    final node = _buildNode();

    try {
      // Verificar que el asset exista (para local)
      if (isLocal) {
        await rootBundle.load(glbPath);
      }

      // Posición delante de cámara
      final cameraPose = await _sessionManager!.getCameraPose();
      vmath.Vector3 placePosition;
      if (cameraPose != null) {
        final m = cameraPose;
        final forward = vmath.Vector3(
          -m.entry(0, 2),
          -m.entry(1, 2),
          -m.entry(2, 2),
        );
        final camPos = vmath.Vector3(
          m.entry(0, 3),
          m.entry(1, 3),
          m.entry(2, 3),
        );
        placePosition = camPos + forward.normalized() * kPlaceDistanceMeters;
      } else {
        placePosition = vmath.Vector3(0, 0, -kPlaceDistanceMeters);
        _showSnack("No se obtuvo pose de cámara (fallback).");
      }
      node.position = placePosition;

      // Reintento de addNode
      final added = await _tryAddNodeWithRetry(node);
      if (!added) {
        throw Exception("addNode() devolvió false tras reintentos.");
      }

      _currentNode = node;
      if (mounted) setState(() => _showReticle = false); // ocultar retícula
      _alert("Colocado", "Modelo agregado desde:\n$glbPath");
    } catch (e, st) {
      debugPrint("❌ Error cargando modelo: $e\n$st");
      _alert(
        "No se pudo cargar el modelo",
        "GLB: $glbPath\n\nError: $e\n\nPosibles causas:\n"
            "• Ruta mal declarada o archivo no incluido en pubspec.yaml.\n"
            "• El GLB no está en formato binario válido o usa extensiones no soportadas (Draco/KTX2/etc).\n"
            "• El dispositivo no soporta ARCore/ARKit.\n"
            "• Falta permiso de cámara.",
      );
    }
  }

  Future<void> _resetPlacement() async {
    await _removeCurrentNode();
    if (mounted) setState(() => _showReticle = true);
  }

  Future<void> _removeCurrentNode() async {
    if (_currentNode != null) {
      try {
        await _objectManager?.removeNode(_currentNode!);
      } catch (_) {}
      _currentNode = null;
    }
  }

  /// ------------------ UI helpers ------------------
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
        content: SingleChildScrollView(child: Text(msg)),
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
