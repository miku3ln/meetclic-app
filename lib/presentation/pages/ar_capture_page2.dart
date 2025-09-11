// lib/ar/ar_capture_page.dart
//
// Pantalla AR con:
// - Colocación del modelo al tocar un plano
// - Panel de controles (escala/offset/rotación + toggles de overlays)
// - Gesto de pinch (2 dedos) en dos modos: Scale y Distance(Z)
// - HUD superior y tira de indicadores a la izquierda
//
// Requiere ar_flutter_plugin 0.7.x y un ARSceneController con:
//   init, placeAt, reconfigureOverlays,
//   setUniformScale, setScaleXYZ, setOffset, setRotationEulerDeg,
//   reset, dispose

import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';
import 'package:ar_flutter_plugin/datatypes/config_planedetection.dart';
import 'package:ar_flutter_plugin/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';
import 'package:flutter/material.dart';
import 'package:meetclic/ar/ar_scene_controller.dart';

class ARCapturePage extends StatefulWidget {
  final String uri; // ej. 'assets/totems/examples/HORNET.glb'
  final bool isLocal; // true: assets, false: URL

  const ARCapturePage({super.key, required this.uri, this.isLocal = true});

  @override
  State<ARCapturePage> createState() => _ARCapturePageState();
}

enum PinchMode { scale, distance }

class _ARCapturePageState extends State<ARCapturePage> {
  // Controlador de escena (maneja sesión, managers y nodo activo)
  final _c = ARSceneController();

  // Overlays de tracking
  bool _showPlanes = true;
  bool _showPoints = true;

  // Transform del modelo
  bool _scaleLocked = true;
  double _sx = 1, _sy = 1, _sz = 1; // escala
  double _rx = 0, _ry = 0, _rz = 0; // rotación en grados
  double _ox = 0, _oy = 0.05, _oz = 0; // offset en metros

  // Estado UI
  bool _hasPlaced = false;
  bool _panelVisible = false;

  // Pinch (2 dedos)
  PinchMode _pinchMode = PinchMode.scale;
  double _pinchStartScale = 1.0;
  double _pinchStartOz = 0.0;

  // Valores iniciales (para HUD/indicadores)
  double _initialScale = 1.0;
  double _initialOz = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ===== AR camera + tracking =====
          // Solo escuchamos pinch (2 dedos). NO declaramos onTap aquí.
          GestureDetector(
            behavior: HitTestBehavior
                .deferToChild, // deja pasar taps/pans al ARView (PlatformView)
            onScaleStart: (d) {
              _pinchStartScale = _sx;
              _pinchStartOz = _oz;
            },
            onScaleUpdate: (details) async {
              if (!_hasPlaced) return;
              // Scale gesture solo cuando hay 2 dedos
              if (details.pointerCount < 2) return;

              if (_pinchMode == PinchMode.scale) {
                final newScale = (_pinchStartScale * details.scale).clamp(
                  0.01,
                  5.0,
                );
                setState(() {
                  _sx = newScale;
                  if (_scaleLocked) _sy = _sz = newScale;
                });
                await _c.setUniformScale(_sx);
              } else {
                // Distance(Z) = acercar/alejar moviendo en Z
                const sensitivity = 0.6; // metros por unidad de pinch
                final dz = (details.scale - 1.0) * sensitivity;
                final newOz = (_pinchStartOz + dz).clamp(-3.0, 3.0);
                setState(() => _oz = newOz);
                await _c.setOffset(_ox, _oy, _oz);
              }
            },
            child: ARView(
              planeDetectionConfig: PlaneDetectionConfig.horizontal,
              onARViewCreated: _onCreated, // 0.7.x: 4 params
            ),
          ),

          // ===== HUD (arriba) =====
          Positioned(
            left: 12,
            right: 12,
            top: 0,
            child: SafeArea(child: (_hasPlaced) ? _hudBar() : _hint()),
          ),

          // ===== Indicadores (columna izquierda) =====
          Positioned(
            top: 72,
            left: 8,
            child: SafeArea(child: _leftIndicators()),
          ),

          // ===== Panel de controles (abajo) =====
          if (_panelVisible)
            Positioned(left: 12, right: 12, bottom: 12, child: _panel(context)),

          // FAB para mostrar panel
          if (!_panelVisible)
            Positioned(
              right: 16,
              bottom: 16,
              child: FloatingActionButton.extended(
                onPressed: () => setState(() => _panelVisible = true),
                label: const Text('Controls'),
                icon: const Icon(Icons.tune),
              ),
            ),
        ],
      ),
    );
  }

  // ---------- HUD superior ----------
  Widget _hudBar() {
    final isScale = _pinchMode == PinchMode.scale;
    final cur = isScale ? _sx : _oz;
    final ini = isScale ? _initialScale : _initialOz;
    final delta = cur - ini;

    final label = isScale ? 'Scale' : 'Dist Z';
    final unit = isScale ? '×' : ' m';

    String fCur = isScale ? cur.toStringAsPrecision(3) : cur.toStringAsFixed(2);
    String fIni = isScale ? ini.toStringAsPrecision(3) : ini.toStringAsFixed(2);
    String fDelta =
        '${delta >= 0 ? '+' : ''}${isScale ? delta.toStringAsPrecision(3) : delta.toStringAsFixed(2)}$unit';

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(12),
        ),
        child: DefaultTextStyle(
          style: const TextStyle(color: Colors.white),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(Icons.pinch, size: 16, color: Colors.white),
                  const SizedBox(width: 6),
                  Text(
                    _pinchMode == PinchMode.scale
                        ? 'Pinch: Scale'
                        : 'Pinch: Distance',
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Text('$label: $fCur$unit'),
              const SizedBox(width: 10),
              Text('init: $fIni$unit'),
              const SizedBox(width: 10),
              Text('Δ: $fDelta'),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- Indicadores izquierda ----------
  Widget _leftIndicators() {
    Widget chip(IconData icon, String text, {bool? on}) {
      final color = on == null
          ? Colors.white12
          : (on ? Colors.green.withOpacity(.25) : Colors.red.withOpacity(.25));
      return Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: Colors.white),
            const SizedBox(width: 6),
            Text(text, style: const TextStyle(color: Colors.white)),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        chip(
          Icons.grid_on,
          'Planes: ${_showPlanes ? "ON" : "OFF"}',
          on: _showPlanes,
        ),
        chip(
          Icons.blur_circular,
          'Features: ${_showPoints ? "ON" : "OFF"}',
          on: _showPoints,
        ),
        chip(
          Icons.swap_calls,
          'Mode: ${_pinchMode == PinchMode.scale ? "Scale" : "Distance"}',
        ),
        chip(Icons.straighten, 'S: ${_sx.toStringAsPrecision(3)}×'),
        chip(
          Icons.vertical_align_center,
          'Z: ${_oz.toStringAsFixed(2)} m (Δ ${((_oz - _initialOz) >= 0 ? '+' : '')}${(_oz - _initialOz).toStringAsFixed(2)})',
        ),
      ],
    );
  }

  // ---------- Hint ----------
  Widget _hint() => Center(
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'Toca un plano para colocar el modelo',
        style: TextStyle(color: Colors.white),
      ),
    ),
  );

  // ---------- ARView creado ----------
  Future<void> _onCreated(
    ARSessionManager s,
    ARObjectManager o,
    ARAnchorManager a,
    ARLocationManager l,
  ) async {
    await _c.init(
      s,
      o,
      showPlanes: _showPlanes,
      showFeaturePoints: _showPoints,
    );

    s.onPlaneOrPointTap = (hits) async {
      if (hits.isEmpty) return;
      await _c.placeAt(hits.first, uri: widget.uri, local: widget.isLocal);
      await _applyPanelToController();
      _initialScale = _sx;
      _initialOz = _oz;
      setState(() => _hasPlaced = true);
    };
  }

  // ---------- Panel ----------
  Widget _panel(BuildContext context) {
    return Card(
      color: Colors.black.withOpacity(0.58),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _switch('Feature points', _showPoints, (v) async {
                      setState(() => _showPoints = v);
                      await _c.reconfigureOverlays(
                        showFeaturePoints: _showPoints,
                        showPlanes: _showPlanes,
                      );
                    }),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _switch('Planes', _showPlanes, (v) async {
                      setState(() => _showPlanes = v);
                      await _c.reconfigureOverlays(
                        showFeaturePoints: _showPoints,
                        showPlanes: _showPlanes,
                      );
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              _sectionTitle('Pinch mode'),
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      selected: _pinchMode == PinchMode.scale,
                      label: const Text('Scale'),
                      onSelected: (_) =>
                          setState(() => _pinchMode = PinchMode.scale),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ChoiceChip(
                      selected: _pinchMode == PinchMode.distance,
                      label: const Text('Distance (Z)'),
                      onSelected: (_) =>
                          setState(() => _pinchMode = PinchMode.distance),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              _sectionTitle('Scale'),
              Row(
                children: [
                  _lockButton(
                    locked: _scaleLocked,
                    onPressed: () =>
                        setState(() => _scaleLocked = !_scaleLocked),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: _axisField('X', _sx)),
                  const SizedBox(width: 8),
                  Expanded(child: _axisField('Y', _sy)),
                  const SizedBox(width: 8),
                  Expanded(child: _axisField('Z', _sz)),
                ],
              ),
              Slider(value: _sx, min: 0.01, max: 5, onChanged: _onScaleUniform),

              _sectionTitle('Offset (m)'),
              Row(
                children: [
                  _lockButton(locked: true, onPressed: () {}),
                  const SizedBox(width: 8),
                  Expanded(child: _axisField('X', _ox)),
                  const SizedBox(width: 8),
                  Expanded(child: _axisField('Y', _oy)),
                  const SizedBox(width: 8),
                  Expanded(child: _axisField('Z', _oz)),
                ],
              ),
              Slider(value: _ox, min: -2, max: 2, onChanged: _onOffsetX),
              Slider(value: _oy, min: -2, max: 2, onChanged: _onOffsetY),
              Slider(value: _oz, min: -2, max: 2, onChanged: _onOffsetZ),

              _sectionTitle('Rotation (°)'),
              _sliderLabeled('X', _rx, -180, 180, _onRotX),
              _sliderLabeled('Y', _ry, -180, 180, _onRotY),
              _sliderLabeled('Z', _rz, -180, 180, _onRotZ),

              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        await _c.reset();
                        setState(() {
                          _sx = _sy = _sz = 1;
                          _rx = _ry = _rz = 0;
                          _ox = 0;
                          _oy = 0.05;
                          _oz = 0;
                          _scaleLocked = true;
                        });
                        _initialScale = _sx;
                        _initialOz = _oz;
                      },
                      child: const Text('Reset'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => setState(() => _panelVisible = false),
                      child: const Text('Close'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- Helpers UI ----------
  Widget _switch(String t, bool val, ValueChanged<bool> onChanged) => Row(
    children: [
      Expanded(
        child: Text(t, style: const TextStyle(color: Colors.white)),
      ),
      Switch(value: val, onChanged: onChanged),
    ],
  );

  Widget _sectionTitle(String t) => Align(
    alignment: Alignment.centerLeft,
    child: Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 6),
      child: Text(
        t,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );

  Widget _lockButton({required bool locked, required VoidCallback onPressed}) {
    return SizedBox(
      width: 38,
      height: 38,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: onPressed,
        child: Icon(locked ? Icons.lock : Icons.lock_open, size: 18),
      ),
    );
  }

  Widget _axisField(String axis, double value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(axis, style: const TextStyle(color: Colors.white)),
          const Spacer(),
          Text(
            value.toStringAsPrecision(3),
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _sliderLabeled(
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ${value.toStringAsFixed(0)}°',
          style: const TextStyle(color: Colors.white),
        ),
        Slider(value: value, min: min, max: max, onChanged: onChanged),
      ],
    );
  }

  // ---------- Aplicación de transformaciones ----------
  Future<void> _applyPanelToController() async {
    if (_scaleLocked) {
      await _c.setUniformScale(_sx);
    } else {
      await _c.setScaleXYZ(_sx, _sy, _sz);
    }
    await _c.setOffset(_ox, _oy, _oz);
    await _c.setRotationEulerDeg(_rx, _ry, _rz);
  }

  // ---------- Handlers sliders ----------
  Future<void> _onScaleUniform(double v) async {
    setState(() {
      _sx = v;
      if (_scaleLocked) _sy = _sz = v;
    });
    await _applyPanelToController();
  }

  Future<void> _onOffsetX(double v) async {
    setState(() => _ox = v);
    await _c.setOffset(_ox, _oy, _oz);
  }

  Future<void> _onOffsetY(double v) async {
    setState(() => _oy = v);
    await _c.setOffset(_ox, _oy, _oz);
  }

  Future<void> _onOffsetZ(double v) async {
    setState(() => _oz = v);
    await _c.setOffset(_ox, _oy, _oz);
  }

  Future<void> _onRotX(double v) async {
    setState(() => _rx = v);
    await _c.setRotationEulerDeg(_rx, _ry, _rz);
  }

  Future<void> _onRotY(double v) async {
    setState(() => _ry = v);
    await _c.setRotationEulerDeg(_rx, _ry, _rz);
  }

  Future<void> _onRotZ(double v) async {
    setState(() => _rz = v);
    await _c.setRotationEulerDeg(_rx, _ry, _rz);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }
}
