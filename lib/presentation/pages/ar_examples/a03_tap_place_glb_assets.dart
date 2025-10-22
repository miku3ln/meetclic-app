// lib/exercises/a03_tap_place_glb_assets.dart
//
// Ejercicio 3 — Tap → Colocar GLB (assets) — CON DIAGNÓSTICO
// -------------------------------------------------------------
// Objetivo:
// - Detectar taps sobre un plano (hit test) y crear un ARPlaneAnchor.
// - Anclar un modelo .glb local (assets) en ese anchor.
// - Permitir quitar el modelo (reset) desde la UI.
// - Mostrar UI/UX de diagnóstico: verifica asset, captura errores paso a paso,
//   y los muestra en pantalla (tarjeta + SnackBar).
//
// Qué verás:
// - Con tracking listo y planos detectados, toca una superficie y se colocará
//   el modelo GLB. Si algo falla, verás el motivo exacto.
//
// Dependencias (pubspec.yaml):
//   ar_flutter_plugin: ^0.9.0
//   vector_math: ^2.1.4
//
// Assets (pubspec.yaml):
//   flutter:
//     assets:
//       - assets/totems/examples/HORNET.glb
//
// Notas Clean Code:
// - Separación de responsabilidades y nombres expresivos.
// - _verifyAssetAvailable(): verifica que el GLB esté empaquetado.
// - _setInfo/_setError: centralizan UI de estado/errores.
// -------------------------------------------------------------

import 'dart:io' show Platform;

import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';
import 'package:ar_flutter_plugin/datatypes/node_types.dart';
import 'package:ar_flutter_plugin/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin/models/ar_anchor.dart';
import 'package:ar_flutter_plugin/models/ar_hittest_result.dart';
import 'package:ar_flutter_plugin/models/ar_node.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'
    show rootBundle; // ← para verificar assets
import 'package:vector_math/vector_math_64.dart' show Vector3;

class A03TapPlaceGlbAssets extends StatefulWidget {
  const A03TapPlaceGlbAssets({super.key});

  @override
  State<A03TapPlaceGlbAssets> createState() => _A03TapPlaceGlbAssetsState();
}

class _A03TapPlaceGlbAssetsState extends State<A03TapPlaceGlbAssets> {
  // Managers del plugin
  ARSessionManager? _arSessionManager;
  ARObjectManager? _arObjectManager;
  ARAnchorManager? _arAnchorManager;
  ARLocationManager? _arLocationManager;

  // Estado de la escena
  ARPlaneAnchor? _placedAnchor;
  ARNode? _placedNode;

  // Estado de UI
  bool _isReady = false; // AR inicializado
  bool _showPlanes = true; // Para depurar colocación
  bool _showWorldOrigin = false;
  String _statusText = 'Inicializando…';
  String? _lastError; // último error para mostrar en UI

  // Config del modelo a colocar (ajústalo a tu asset)
  static const String _assetGlbPath = 'assets/totems/examples/HORNET.glb';
  static Vector3 _defaultScale = Vector3(0.2, 0.2, 0.2); // 20% del tamaño

  // Utilidades de estado (mensajes)
  void _setInfo(String msg) {
    debugPrint('[INFO] $msg');
    if (!mounted) return;
    setState(() {
      _statusText = msg;
      // No tocamos _lastError aquí
    });
  }

  void _setError(String msg) {
    debugPrint('[ERROR] $msg');
    if (!mounted) return;
    setState(() {
      _lastError = msg;
      _statusText = 'Error: $msg';
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    _arSessionManager?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topChips = Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _StateChip(
          label: _isReady ? 'AR: Listo' : 'AR: Cargando…',
          on: _isReady,
          icon: Icons.check_circle,
        ),
        _StateChip(
          label: _showPlanes ? 'Planos: ON' : 'Planos: OFF',
          on: _showPlanes,
          icon: Icons.grid_on,
        ),
        _StateChip(
          label: _placedNode == null
              ? 'Modelo: No colocado'
              : 'Modelo: Colocado',
          on: _placedNode != null,
          icon: Icons.toys,
        ),
      ],
    );

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('A03 — Tap → Colocar GLB (assets)'),
        actions: [
          IconButton(
            tooltip: 'Ayuda',
            icon: const Icon(Icons.help_outline),
            onPressed: _showHelp,
          ),
        ],
      ),
      body: Stack(
        children: [
          // ARView con callback de 4 parámetros (sin async)
          ARView(onARViewCreated: _onARViewCreated),

          // Chips de estado
          Positioned(left: 12, right: 12, top: 12, child: topChips),

          // Leyenda / estado abajo (incluye último error si existe)
          Positioned(
            left: 12,
            right: 12,
            bottom: 92,
            child: _StatusCard(
              statusText: _statusText,
              extra: _placedNode == null
                  ? 'Toca un plano para colocar el modelo.'
                  : 'Toca otro punto para reubicar (se reemplaza).',
              errorText: _lastError,
            ),
          ),
        ],
      ),

      // Barra inferior con acciones
      bottomNavigationBar: _BottomBar(
        onReset: _removePlacedModel,
        onTogglePlanes: (v) => _toggleDebug(planes: v),
        showPlanes: _showPlanes,
      ),
    );
  }

  // Callback de creación: firma correcta (void, 4 managers)
  void _onARViewCreated(
    ARSessionManager arSessionManager,
    ARObjectManager arObjectManager,
    ARAnchorManager arAnchorManager,
    ARLocationManager arLocationManager,
  ) {
    _arSessionManager = arSessionManager;
    _arObjectManager = arObjectManager;
    _arAnchorManager = arAnchorManager;
    _arLocationManager = arLocationManager;

    _initArSession(); // Inicialización asíncrona
    _wireSessionCallbacks(); // Conectar callbacks de taps
  }

  // Inicializa la sesión AR con opciones de debug útiles para este ejercicio
  Future<void> _initArSession() async {
    if (_arSessionManager == null) {
      _setError('ARSessionManager no inicializado.');
      return;
    }

    try {
      await _arSessionManager!.onInitialize(
        showFeaturePoints: false,
        showPlanes: _showPlanes, // mostramos planos para saber dónde tocar
        showWorldOrigin: _showWorldOrigin,
        handlePans: false,
        handleRotation: false,
        handleTaps: true, // ← necesario para recibir taps
      );

      if (!mounted) return;
      _lastError = null; // limpia último error si lo hubiera
      setState(() {
        _isReady = true;
        _statusText = Platform.isAndroid
            ? 'Listo. Apunta a una superficie y toca para colocar. (ARCore)'
            : 'Listo. Apunta a una superficie y toca para colocar. (ARKit)';
      });
    } catch (e) {
      _setError('Fallo al iniciar la sesión AR: $e');
    }
  }

  // Conecta el callback de taps (vive en ARSessionManager)
  void _wireSessionCallbacks() {
    _arSessionManager?.onPlaneOrPointTap = (List<ARHitTestResult> hits) async {
      if (hits.isEmpty) {
        _setError(
          'No hubo impacto de hit-test. Asegúrate de tocar un plano detectado.',
        );
        return;
      }
      await _placeModelAtHit(hits.first);
    };
  }

  // Verifica que el asset GLB exista en el bundle
  Future<bool> _verifyAssetAvailable(String assetPath) async {
    try {
      await rootBundle.load(assetPath); // si no existe → FlutterError
      debugPrint('[ASSET] OK $assetPath');
      return true;
    } catch (e) {
      _setError('Asset no encontrado: $assetPath — Detalle: $e');
      return false;
    }
  }

  // Coloca (o recoloca) el modelo en el primer impacto válido
  Future<void> _placeModelAtHit(ARHitTestResult hit) async {
    // 0) Verifica que el asset exista en el bundle
    final hasAsset = await _verifyAssetAvailable(_assetGlbPath);
    if (!hasAsset) return;

    // 1) Si ya hay algo colocado, lo quitamos para reemplazar
    if (_placedNode != null || _placedAnchor != null) {
      await _removePlacedModel();
    }

    // 2) Crear anchor a partir de la transform del impacto
    final anchor = ARPlaneAnchor(transformation: hit.worldTransform);
    bool? didAddAnchor = false;
    try {
      didAddAnchor = await _arAnchorManager!.addAnchor(anchor);
    } catch (e) {
      _setError('Fallo addAnchor(): $e');
      return;
    }
    if (didAddAnchor != true) {
      _setError('addAnchor() devolvió false');
      return;
    }

    // 3) Crear el nodo con el modelo GLB local
    final node = ARNode(
      type: NodeType.localGLTF2,
      uri: _assetGlbPath, // ruta relativa en assets/
      scale: _defaultScale,
    );

    bool? didAddNode = false;
    try {
      didAddNode = await _arObjectManager!.addNode(node, planeAnchor: anchor);
    } catch (e) {
      _setError('Fallo addNode(): $e');
      // Limpieza si falló el nodo
      await _arAnchorManager!.removeAnchor(anchor);
      return;
    }
    if (didAddNode != true) {
      _setError('addNode() devolvió false');
      await _arAnchorManager!.removeAnchor(anchor);
      return;
    }

    if (!mounted) return;
    _lastError = null;
    setState(() {
      _placedAnchor = anchor;
      _placedNode = node;
      _statusText = 'Modelo colocado ✔';
    });
  }

  // Quita el modelo/anchor si existen
  Future<void> _removePlacedModel() async {
    try {
      if (_placedNode != null) {
        await _arObjectManager?.removeNode(_placedNode!);
        _placedNode = null;
      }
    } catch (e) {
      _setError('Fallo removeNode(): $e');
    }

    try {
      if (_placedAnchor != null) {
        await _arAnchorManager?.removeAnchor(_placedAnchor!);
        _placedAnchor = null;
      }
    } catch (e) {
      _setError('Fallo removeAnchor(): $e');
    }

    if (!mounted) return;
    setState(() => _statusText = 'Modelo eliminado.');
  }

  // Alterna opciones de debug y reaplica onInitialize
  Future<void> _toggleDebug({bool? planes}) async {
    if (planes != null) _showPlanes = planes;
    setState(() {}); // refresca switches

    if (_arSessionManager == null) {
      _setError('ARSessionManager no inicializado.');
      return;
    }

    try {
      await _arSessionManager!.onInitialize(
        showFeaturePoints: false,
        showPlanes: _showPlanes,
        showWorldOrigin: _showWorldOrigin,
        handlePans: false,
        handleRotation: false,
        handleTaps: true,
      );
      _setInfo('Opciones aplicadas → Planos: ${_showPlanes ? "ON" : "OFF"}');
    } catch (e) {
      _setError('Error al reconfigurar opciones: $e');
    }
  }

  void _showHelp() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        final st = Theme.of(
          ctx,
        ).textTheme.bodyMedium?.copyWith(color: Colors.white);
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: DefaultTextStyle(
            style: st ?? const TextStyle(color: Colors.white),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  '¿Qué hace este ejercicio?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  '• Detecta el tap sobre un plano y crea un anchor en ese punto.',
                ),
                Text('• Coloca un modelo .glb local anclado a ese plano.'),
                Text('• Botón para quitar y volver a colocar donde toques.'),
                SizedBox(height: 12),
                Text(
                  'Diagnóstico: si el asset no existe o falla addAnchor/addNode, verás el error.',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Chip de estado (ON/OFF) con color contextual
class _StateChip extends StatelessWidget {
  final String label;
  final bool on;
  final IconData icon;

  const _StateChip({required this.label, required this.on, required this.icon});

  @override
  Widget build(BuildContext context) {
    final color = on ? Colors.greenAccent : Colors.grey;
    return Chip(
      avatar: Icon(icon, size: 18, color: Colors.black),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      backgroundColor: color,
    );
  }
}

/// Tarjeta de mensajes de estado con leyenda + último error
class _StatusCard extends StatelessWidget {
  final String statusText;
  final String? extra;
  final String? errorText;
  const _StatusCard({required this.statusText, this.extra, this.errorText});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: Colors.black.withOpacity(0.55),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: DefaultTextStyle(
          style: theme.textTheme.bodyMedium!.copyWith(color: Colors.white),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                statusText,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (extra != null) ...[
                const SizedBox(height: 6),
                Text(
                  extra!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
              if (errorText != null) ...[
                const SizedBox(height: 8),
                Text(
                  '⚠️ $errorText',
                  style: const TextStyle(color: Colors.orangeAccent),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Barra inferior con acción de reset y toggle de planos
class _BottomBar extends StatelessWidget {
  final VoidCallback onReset;
  final ValueChanged<bool> onTogglePlanes;
  final bool showPlanes;

  const _BottomBar({
    required this.onReset,
    required this.onTogglePlanes,
    required this.showPlanes,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.8),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: [
          ElevatedButton.icon(
            icon: const Icon(Icons.delete),
            label: const Text('Quitar modelo'),
            onPressed: onReset,
          ),
          const Spacer(),
          Row(
            children: [
              const Icon(Icons.grid_on, color: Colors.white),
              const SizedBox(width: 8),
              const Text('Planos', style: TextStyle(color: Colors.white)),
              const SizedBox(width: 8),
              Switch(
                value: showPlanes,
                onChanged: onTogglePlanes,
                activeColor: Colors.lightGreenAccent,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
