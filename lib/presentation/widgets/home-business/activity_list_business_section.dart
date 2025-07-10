import 'package:flutter/material.dart';
import 'activity_item_business_section.dart';
import '../../../domain/entities/business.dart';

class ActivityListBusiness extends StatelessWidget {
  final BusinessData businessData;
  const ActivityListBusiness({super.key,required this.businessData});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: const [
        ActivityItemBusiness(
          icon: Icons.local_laundry_service,
          title: 'Wash yesterday\'s clothes',
          subtitle: 'The whole life should wash',
          color: Colors.orangeAccent,
          time: 'Just now',
        ),
        ActivityItemBusiness(
          icon: Icons.book,
          title: 'Read a design journal',
          subtitle: 'Be the best designer',
          color: Colors.blueAccent,
          time: '3 h later',
        ),
        ActivityItemBusiness(
          icon: Icons.attach_money,
          title: 'Go to the bank',
          subtitle: 'Take out the design fee',
          color: Colors.green,
          time: '6 h later',
        ),
        ActivityItemBusiness(
          icon: Icons.palette,
          title: 'Post a work on dribbble',
          subtitle: 'Hope to be recognized',
          color: Colors.pinkAccent,
          time: '7 h later',
        ),
      ],
    );
  }
}
