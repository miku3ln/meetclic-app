import 'package:flutter/material.dart';

class GridViewHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(child: Text('Document', style: TextStyle(fontWeight: FontWeight.bold))),
        Expanded(child: Text('Full Name', style: TextStyle(fontWeight: FontWeight.bold))),
        Expanded(child: Text('Adult/Child', style: TextStyle(fontWeight: FontWeight.bold))),
        Expanded(child: Text('Age', style: TextStyle(fontWeight: FontWeight.bold))),
      ],
    );
  }
}
