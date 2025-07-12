import 'package:flutter/material.dart';



class MenuTabUpItem {
  final String name;
  final String asset;
  final int number;
  final VoidCallback? onTap;
  MenuTabUpItem({
    required this.name,
    required this.asset,
    required this.number,
     this.onTap,
  });
}