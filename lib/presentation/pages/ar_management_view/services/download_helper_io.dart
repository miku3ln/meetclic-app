import 'dart:io';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'app_cache_manager.dart';
import 'download_models.dart';

class DownloadHelper {
  /// Descarga un recurso a caché con progreso (IO).
  /// Retorna un path LOCAL (válido para NodeFactory.localFileGlb).
  static Future<DownloadResult> fetchToCacheVerbose(
    String url, {
    Map<String, String>? headers,
    ProgressCb? onProgress,
    Duration connectTimeout = const Duration(seconds: 15),
    Duration receiveTimeout = const Duration(seconds: 60),
    int maxRetries = 1,
  }) async {
    for (int attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        final stream = AppCacheManager().getFileStream(
          url,
          withProgress: true,
          headers: headers,
        );

        File? file;
        int lastR = 0, lastT = 0;

        await for (final resp in stream) {
          if (resp is DownloadProgress) {
            lastR = resp.downloaded;
            lastT = resp.totalSize ?? 0;
            onProgress?.call(lastR, lastT);
          } else if (resp is FileInfo) {
            file = resp.file;
          }
        }

        if (file != null && await file!.exists()) {
          final total = lastT > 0 ? lastT : await file!.length();
          return DownloadResult(
            success: true,
            data: file!.path,
            bytesReceived: total,
            totalBytes: total,
            extra: const {'isBlob': false},
          );
        }
        return const DownloadResult(
          success: false,
          message: 'No se pudo cachear recurso',
        );
      } catch (e) {
        if (attempt == maxRetries) {
          return DownloadResult(success: false, message: e.toString());
        }
        await Future.delayed(const Duration(milliseconds: 350));
      }
    }
    return const DownloadResult(success: false, message: 'Descarga cancelada.');
  }

  /// IO: no hay blob URLs; no hace nada.
  static void revokeIfNeeded(String? url) {
    /* noop */
  }
}
