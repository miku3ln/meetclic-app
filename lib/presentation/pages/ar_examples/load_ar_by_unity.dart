import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_unity_widget/flutter_unity_widget.dart';
import 'package:meetclic/models/totem_management.dart';

class LoadArByUnity extends StatefulWidget {
  final ItemAR item;
  const LoadArByUnity({super.key, required this.item});

  @override
  State<LoadArByUnity> createState() => _LoadArByUnityState();
}

class _LoadArByUnityState extends State<LoadArByUnity> {
  UnityWidgetController? _unity;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return Scaffold(
      body: Stack(
        children: [
          UnityWidget(
            onUnityCreated: (c) async {
              _unity = c;

              // payload mínimo (Unity tendrá defaults si algún campo falta)
              final payload = {
                "glbUrl": item.sources.glb,
                "distance": 1.0,
                "uniformScale": 0.2,
                "localEuler": "0,180,0",
                "followCamera": true,
              };

              // 'AR Camera' = nombre del GameObject con tu Bridge/Loader
              _unity!.postMessage('AR Camera', 'InitAR', jsonEncode(payload));
            },
            useAndroidViewSurface: true,
            fullscreen: true,
          ),

          // Cerrar
          Positioned(
            top: 40,
            right: 20,
            child: FloatingActionButton.small(
              heroTag: 'close_ar',
              backgroundColor: Colors.black54,
              onPressed: () => Navigator.pop(context),
              child: const Icon(Icons.close, color: Colors.white),
            ),
          ),

          // Info breve
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: _InfoCard(item: item),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final ItemAR item;
  const _InfoCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                "${item.title}\n${item.subtitle}",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () {
                // Aquí podrías abrir detalles o alternar otro modelo
              },
              child: const Text("Detalles"),
            ),
          ],
        ),
      ),
    );
  }
}
