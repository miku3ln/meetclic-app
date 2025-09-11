import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';
import 'package:ar_flutter_plugin/datatypes/config_planedetection.dart';
import 'package:ar_flutter_plugin/datatypes/node_types.dart';
import 'package:ar_flutter_plugin/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin/models/ar_node.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as v;

class ARCapturePage extends StatefulWidget {
  const ARCapturePage({super.key});
  @override
  State<ARCapturePage> createState() => _ARCapturePageState();
}

class _ARCapturePageState extends State<ARCapturePage> {
  ARSessionManager? _session;
  ARObjectManager? _objects;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ARView(
        planeDetectionConfig: PlaneDetectionConfig.horizontal,
        onARViewCreated: _onARViewCreated, // API 0.7.x: 4 params
      ),
    );
  }

  Future<void> _onARViewCreated(
    ARSessionManager sessionManager,
    ARObjectManager objectManager,
    ARAnchorManager anchorManager,
    ARLocationManager locationManager,
  ) async {
    _session = sessionManager;
    _objects = objectManager;

    _session!.onPlaneOrPointTap = (hits) async {
      if (hits.isEmpty) return;
      final hit = hits.first;

      final node = ARNode(
        type: NodeType.localGLTF2,
        uri: 'assets/totems/examples/HORNET.glb', // ajusta a tu GLB
        position: hit.worldTransform.getTranslation(),
        rotation: v.Vector4(0, 1, 0, 0),
        scale: v.Vector3(1, 1, 1),
      );

      final ok = await _objects!.addNode(node);
      if (ok == true) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Model placed')));
      }
    };
  }
}
