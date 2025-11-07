import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

/// Descarga y cachea un GLB remoto. Devuelve la ruta local absoluta.
/// Si ya existe en caché, no re-descarga.
Future<String> downloadAndCacheGlb(String url) async {
  final tmp = await getTemporaryDirectory();
  final hash = md5.convert(utf8.encode(url)).toString();
  final file = File('${tmp.path}/$hash.glb');

  if (await file.exists() && await file.length() > 0) {
    return file.path;
  }

  final res = await http.get(Uri.parse(url));
  if (res.statusCode != 200) {
    throw Exception('HTTP ${res.statusCode} al descargar GLB');
  }

  await file.writeAsBytes(res.bodyBytes);
  return file.path;
}
