import 'package:flutter/material.dart';

class ActivityItemBusiness extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final String time;

  const ActivityItemBusiness({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.2),
        child: Icon(icon, color: color),
      ),
      title: Text(title),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: Text(time, style: const TextStyle(color: Colors.grey)),
    );
  }
}
