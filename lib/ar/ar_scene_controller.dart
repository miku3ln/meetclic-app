import 'dart:math' as math;

import 'package:ar_flutter_plugin/datatypes/node_types.dart';
import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin/models/ar_hittest_result.dart';
import 'package:ar_flutter_plugin/models/ar_node.dart';
import 'package:vector_math/vector_math_64.dart' as vm;

class ARSceneController {
  ARSessionManager? session;
  ARObjectManager? objects;

  ARNode? node;

  // Fuente del modelo
  String? currentUri;
  bool isLocal = true; // true => assets/, false => URL

  // Transform actual (en metros y radianes)
  double sx = 1, sy = 1, sz = 1; // escala
  double rx = 0, ry = 0, rz = 0; // rotación Euler XYZ (rad)
  double px = 0, py = 0.05, pz = 0; // offset relativo al plano golpeado

  vm.Vector3? _hitBase; // base desde el último tap

  /// Inicializa managers y muestra overlays iniciales
  Future<void> init(
    ARSessionManager s,
    ARObjectManager o, {
    bool showPlanes = true,
    bool showFeaturePoints = true,
  }) async {
    session = s;
    objects = o;

    await session!.onInitialize(
      showFeaturePoints: showFeaturePoints,
      showPlanes: showPlanes,
      customPlaneTexturePath: null,
      showWorldOrigin: false,
      handleTaps: false, // manejamos taps manualmente
    );
    await objects!.onInitialize();
  }

  /// Reconfigura overlays (0.7.x: no hay setters; se relanza onInitialize)
  Future<void> reconfigureOverlays({
    required bool showFeaturePoints,
    required bool showPlanes,
  }) async {
    await session?.onInitialize(
      showFeaturePoints: showFeaturePoints,
      showPlanes: showPlanes,
      customPlaneTexturePath: null,
      showWorldOrigin: false,
      handleTaps: false,
    );
  }

  /// Coloca el modelo en el primer tap sobre un plano
  Future<void> placeAt(
    ARHitTestResult hit, {
    required String uri,
    required bool local,
  }) async {
    currentUri = uri;
    isLocal = local;
    final t = hit.worldTransform.getTranslation();
    _hitBase = vm.Vector3(t.x, t.y, t.z);
    await _rebuildNode();
  }

  /// Setters de transform
  Future<void> setUniformScale(double s) async {
    sx = s;
    sy = s;
    sz = s;
    await _rebuildNodeIfPlaced();
  }

  Future<void> setScaleXYZ(double x, double y, double z) async {
    sx = x;
    sy = y;
    sz = z;
    await _rebuildNodeIfPlaced();
  }

  Future<void> setRotationEulerDeg(
    double degX,
    double degY,
    double degZ,
  ) async {
    rx = _deg2rad(degX);
    ry = _deg2rad(degY);
    rz = _deg2rad(degZ);
    await _rebuildNodeIfPlaced();
  }

  Future<void> setOffset(double x, double y, double z) async {
    px = x;
    py = y;
    pz = z;
    await _rebuildNodeIfPlaced();
  }

  Future<void> reset() async {
    sx = sy = sz = 1;
    rx = ry = rz = 0;
    px = 0;
    py = 0.05;
    pz = 0;
    await _rebuildNodeIfPlaced();
  }

  /// Limpieza (0.7.x no expone dispose() en ARObjectManager)
  Future<void> dispose() async {
    if (node != null) {
      await objects?.removeNode(node!);
      node = null;
    }
    await session?.dispose();
  }

  // -------------------- Internos --------------------

  double _deg2rad(double d) => d * math.pi / 180.0;

  vm.Vector3 _position() =>
      (_hitBase ?? vm.Vector3.zero()) + vm.Vector3(px, py, pz);

  /// 0.7.x usa rotación axis-angle (Vector4). Convertimos desde Euler XYZ.
  vm.Vector4 _axisAngleFromEuler() {
    final qx = vm.Quaternion.axisAngle(vm.Vector3(1, 0, 0), rx);
    final qy = vm.Quaternion.axisAngle(vm.Vector3(0, 1, 0), ry);
    final qz = vm.Quaternion.axisAngle(vm.Vector3(0, 0, 1), rz);
    final q = qz * qy * qx; // orden Z * Y * X

    // Quaternion -> axis-angle
    final angle = 2.0 * math.acos(q.w.clamp(-1.0, 1.0));
    final s = math.sqrt(math.max(1e-12, 1 - q.w * q.w));
    final axis = (s < 1e-6)
        ? vm.Vector3(1, 0, 0)
        : vm.Vector3(q.x / s, q.y / s, q.z / s);

    return vm.Vector4(axis.x, axis.y, axis.z, angle);
  }

  Future<void> _rebuildNodeIfPlaced() async {
    if (_hitBase == null || currentUri == null) return;
    await _rebuildNode();
  }

  Future<void> _rebuildNode() async {
    if (node != null) {
      await objects?.removeNode(node!);
      node = null;
    }
    final pos = _position();
    final rot = _axisAngleFromEuler();

    node = ARNode(
      type: isLocal ? NodeType.localGLTF2 : NodeType.webGLB,
      uri: currentUri!,
      position: pos,
      rotation: rot, // axis-angle
      scale: vm.Vector3(sx, sy, sz),
    );
    await objects?.addNode(node!);
  }
}
