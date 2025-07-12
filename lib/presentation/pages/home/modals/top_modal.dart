import 'package:flutter/material.dart';
void showTopModal(BuildContext context, String title) {
  final overlay = Overlay.of(context);
  final screenSize = MediaQuery.of(context).size;
  final modalHeight = screenSize.height * 0.3;

  late OverlayEntry entry;

  entry = OverlayEntry(
    builder: (_) => Stack(
      children: [
        GestureDetector(
          onTap: () => entry.remove(),
          child: Container(
            width: screenSize.width,
            height: screenSize.height,
            color: Colors.black.withOpacity(0.4),
          ),
        ),
        Positioned(
          top: 73,
          left: 0,
          right: 0,
          child: Material(
            color: Colors.transparent,
            child: Container(
              margin: const EdgeInsets.only(top: 20),
              width: screenSize.width,
              height: modalHeight,
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  const Text("Aquí iría el contenido del modal..."),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () => entry.remove(),
                    child: const Text("Cerrar"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );

  overlay.insert(entry);
}
