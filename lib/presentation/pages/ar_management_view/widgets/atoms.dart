import 'package:flutter/material.dart';

class ARIconCircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;

  const ARIconCircleButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final btn = ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(14),
        backgroundColor: Colors.black.withOpacity(0.40),
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      onPressed: onPressed,
      child: Icon(icon, size: 22),
    );
    return tooltip != null ? Tooltip(message: tooltip!, child: btn) : btn;
  }
}
