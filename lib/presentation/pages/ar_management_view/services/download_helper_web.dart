// Se usa solo vía import condicional desde download_helper.dart.
// No usa 'dart:html'. Para Flutter Web crea data:URIs cuando el tamaño lo permite,
// o retorna la URL original (http/https) si no es viable calcular/usar porcentaje.

import 'package:dio/dio.dart';

import 'download_models.dart';

class DownloadHelper {
  // Límite recomendado para crear data:URI (evitar URLs enormes en Web).
  // Ajusta a tu gusto. 8–12 MB suele ser razonable.
  static const int _defaultDataUriMaxBytes = 8 * 1024 * 1024; // 8 MB

  /// Descarga con progreso y devuelve:
  /// - data:URI (cuando el archivo es pequeño y se pudo descargar con %)
  /// - o la URL original (http/https) cuando no es viable (entonces % no aplica)
  ///
  /// Comportamiento del %:
  /// - Si el server entrega Content-Length y el tamaño <= _defaultDataUriMaxBytes:
  ///     -> hacemos GET con onReceiveProgress => `onProgress(r,t)` con t>0 (muestra %)
  ///     -> devolvemos `data:` URI en `data` (isLocal=false)
  /// - Si NO hay Content-Length o el tamaño excede el umbral:
  ///     -> devolvemos la URL `url` tal cual, sin descargar (onProgress no se usa)
  ///     -> tu UI debe mostrar loader indeterminado (como ya lo haces)
  static Future<DownloadResult> fetchToCacheVerbose(
    String url, {
    Map<String, String>? headers,
    ProgressCb? onProgress,
    Duration connectTimeout = const Duration(seconds: 15),
    Duration receiveTimeout = const Duration(seconds: 60),
    int maxRetries = 1,
    int dataUriMaxBytes = _defaultDataUriMaxBytes,
  }) async {
    final dio = Dio(
      BaseOptions(
        connectTimeout: connectTimeout, // Duration? en Dio v5
        receiveTimeout: receiveTimeout, // Duration? en Dio v5
        responseType: ResponseType.bytes,
        headers: headers,
        followRedirects: true,
        receiveDataWhenStatusError: true,
      ),
    );

    // 1) Intentar HEAD para conocer Content-Length
    int? contentLength;
    try {
      final head = await dio.head(url);
      final lenStr = head.headers.value('content-length');
      if (lenStr != null) contentLength = int.tryParse(lenStr);
    } catch (_) {
      // Algunos CDNs no permiten HEAD; seguimos sin tamaño conocido.
    }

    // 2) Decidir estrategia
    final canDownloadWithPercent =
        (contentLength != null &&
        contentLength > 0 &&
        contentLength <= dataUriMaxBytes);

    if (!canDownloadWithPercent) {
      // No haremos descarga previa; dejamos que el visor cargue directo.
      // => No habrá % (usa tu loader indeterminado)
      return DownloadResult(
        success: true,
        data: url, // http/https
        // bytes* y total* se omiten (desconocidos)
        extra: const {'isDataUri': false},
      );
    }

    // 3) Descarga con % y construcción de data:URI (tamaño acotado)
    for (int attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        final res = await dio.get<List<int>>(
          url,
          onReceiveProgress: (r, t) {
            if (onProgress != null) {
              // t debería ser == contentLength y > 0
              onProgress(r, t);
            }
          },
          options: Options(responseType: ResponseType.bytes),
        );

        final status = res.statusCode ?? 0;
        final data = res.data;

        if (status == 200 && data != null) {
          // data:URI sin usar dart:html
          // OJO: puede ser grande si subes el umbral; mantén el límite razonable.
          final dataUri = Uri.dataFromBytes(
            data,
            mimeType: 'model/gltf-binary',
            // encoding null para binario; no seteamos base64 explícito (se infiere)
          ).toString();

          return DownloadResult(
            success: true,
            data: dataUri, // <-- úsala como URL en Web
            bytesReceived: data.length,
            totalBytes: contentLength ?? data.length,
            extra: const {'isDataUri': true},
          );
        }

        return DownloadResult(success: false, message: 'HTTP $status');
      } catch (e) {
        if (attempt == maxRetries) {
          return DownloadResult(success: false, message: e.toString());
        }
        await Future.delayed(const Duration(milliseconds: 350));
      }
    }

    return const DownloadResult(success: false, message: 'Descarga cancelada.');
  }

  // En esta implementación no generamos blob:URL, así que no hay nada que revocar.
  static void revokeIfNeeded(String? url) {
    /* noop */
  }
}
