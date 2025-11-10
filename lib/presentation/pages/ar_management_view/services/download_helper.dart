// lib/features/ar_management_view/services/download_helper.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

typedef ProgressCb = void Function(int received, int? total);

class DownloadResult {
  final bool success;
  final String message;
  final String? data; // ruta local cuando success==true

  const DownloadResult({
    required this.success,
    required this.message,
    this.data,
  });

  factory DownloadResult.ok(String path) =>
      DownloadResult(success: true, message: 'OK', data: path);

  factory DownloadResult.err(String msg) =>
      DownloadResult(success: false, message: msg);
}

class DownloadHelper {
  DownloadHelper._();

  /// Descarga un .glb a caché (si no existe) y retorna:
  ///  - success: true/false
  ///  - message: descripción del resultado o error
  ///  - data: ruta local del archivo en caché (cuando success==true)
  static Future<DownloadResult> fetchToCacheVerbose(
    String url, {
    ProgressCb? onProgress,
    Duration connectTimeout = const Duration(seconds: 12),
    Duration receiveTimeout = const Duration(seconds: 30),
    int maxRetries = 2,
    bool requireGlbExtension = true,
  }) async {
    // Validación básica de URL http/https
    Uri? uri;
    try {
      uri = Uri.parse(url);
      if (!(uri.isScheme('http') || uri.isScheme('https'))) {
        return DownloadResult.err('URL no http/https: $url');
      }
    } catch (_) {
      return DownloadResult.err('URL inválida: $url');
    }

    // Validación de extensión (opcional, pero útil)
    if (requireGlbExtension && !url.toLowerCase().trim().endsWith('.glb')) {
      return DownloadResult.err('El recurso no parece .glb ($url)');
    }

    // Archivo destino determinístico (hash del URL)
    final cacheDir = await getTemporaryDirectory();
    final name = md5.convert(utf8.encode(url)).toString() + '.glb';
    final file = File('${cacheDir.path}/$name');

    // Hit de caché (caliente)
    if (await file.exists()) {
      try {
        final len = await file.length();
        if (len > 0) {
          return DownloadResult.ok(file.path);
        } else {
          // archivo vacío => reintentar (bórralo)
          await file.delete().catchError((_) {});
        }
      } catch (e) {
        // si falla el length o delete, seguimos con descarga
        debugPrint('[DL] cache file check error: $e');
      }
    }

    int attempt = 0;
    while (true) {
      attempt++;
      http.Client? client;

      try {
        client = http.Client();
        final req = http.Request('GET', uri)
          ..headers.addAll({
            'Accept': 'model/gltf-binary,application/octet-stream,*/*',
            'Connection': 'keep-alive',
          });

        // Conexión con timeout
        final resp = await client
            .send(req)
            .timeout(connectTimeout); // handshake/headers timeout

        if (resp.statusCode != 200) {
          return DownloadResult.err('HTTP ${resp.statusCode} descargando GLB');
        }

        final total = resp.contentLength; // puede ser null (chunked)
        int received = 0;

        // Abrimos el sink del archivo. Si existía vacío, lo reescribimos
        final sink = file.openWrite(mode: FileMode.write);

        // Stream de bytes con timeout por trozos
        final stream = resp.stream.timeout(
          receiveTimeout,
          onTimeout: (s) {
            throw const SocketException('receive timeout');
          },
        );

        await for (final chunk in stream) {
          sink.add(chunk);
          received += chunk.length;
          if (onProgress != null) {
            onProgress(received, total);
          }
        }

        await sink.flush();
        await sink.close();
        client.close();

        // Validar archivo final
        final len = await file.length();
        if (len == 0) {
          // archivo vacío => error
          await file.delete().catchError((_) {});
          return DownloadResult.err('Archivo descargado vacío');
        }

        // OK
        return DownloadResult.ok(file.path);
      } on SocketException catch (e) {
        // Errores de red típicos
        debugPrint('[DL] SocketException: $e (attempt $attempt/$maxRetries)');
        if (attempt > maxRetries) {
          return DownloadResult.err('Red inestable: $e');
        }
        await Future.delayed(Duration(milliseconds: 300 * attempt * attempt));
      } on http.ClientException catch (e) {
        debugPrint('[DL] ClientException: $e (attempt $attempt/$maxRetries)');
        if (attempt > maxRetries) {
          return DownloadResult.err('Cliente HTTP falló: $e');
        }
        await Future.delayed(Duration(milliseconds: 300 * attempt * attempt));
      } on TimeoutException catch (e) {
        debugPrint('[DL] Timeout: $e (attempt $attempt/$maxRetries)');
        if (attempt > maxRetries) {
          return DownloadResult.err('Tiempo de espera agotado');
        }
        await Future.delayed(Duration(milliseconds: 300 * attempt * attempt));
      } catch (e, st) {
        debugPrint('[DL] Error inesperado: $e\n$st');
        if (attempt > maxRetries) {
          return DownloadResult.err('Error descargando GLB: $e');
        }
        await Future.delayed(Duration(milliseconds: 300 * attempt * attempt));
      } finally {
        client?.close();
      }
    }
  }
}
