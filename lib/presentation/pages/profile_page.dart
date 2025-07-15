import 'package:flutter/material.dart';

import '../../../presentation/widgets/template/custom_app_bar.dart';
import 'package:meetclic/domain/entities/menu_tab_up_item.dart';
import 'package:meetclic/presentation/pages/profile-page/organisms/user-profile-header.dart';


class ProfilePage extends StatefulWidget {
  final String title;
  final List<MenuTabUpItem> itemsStatus;

  const ProfilePage({
    super.key,
    required this.title,
    required this.itemsStatus,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(title: widget.title, items: widget.itemsStatus),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UserProfileHeader()
            ],
          ),
        ),
      ),
    );
  }
}
