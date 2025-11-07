import 'package:ar_flutter_plugin/datatypes/node_types.dart';
import 'package:ar_flutter_plugin/models/ar_node.dart';
import 'package:vector_math/vector_math_64.dart' as v;

import 'ar_config.dart';

class NodeFactory {
  NodeFactory._();

  static bool isValidGlbUrl(String url) {
    if (url.isEmpty) return false;
    final u = Uri.tryParse(url);
    return u != null &&
        (u.isScheme('http') || u.isScheme('https')) &&
        u.path.toLowerCase().endsWith('.glb');
  }

  static bool isLocalGlbPath(String path) {
    return path.endsWith('.glb'); // simple, asumiendo ruta absoluta válida
  }

  static ARNode webGlb({
    required String url,
    required v.Vector3 position,
    required v.Vector3 eulerAngles,
    double uniformScale = ARConfig.uniformScale,
  }) {
    return ARNode(
      type: NodeType.webGLB,
      uri: url,
      position: position,
      eulerAngles: eulerAngles,
      scale: v.Vector3.all(uniformScale),
    );
  }

  static ARNode localGlb({
    required String path,
    required v.Vector3 position,
    required v.Vector3 eulerAngles,
    double uniformScale = ARConfig.uniformScale,
  }) {
    return ARNode(
      type: NodeType.localGLB, // 👈 soportado por ar_flutter_plugin
      uri: path, // ruta absoluta del archivo .glb en disco
      position: position,
      eulerAngles: eulerAngles,
      scale: v.Vector3.all(uniformScale),
    );
  }
}
