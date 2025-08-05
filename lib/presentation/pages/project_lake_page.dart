import 'package:flutter/material.dart';

import '../../../presentation/widgets/template/custom_app_bar.dart';
import 'package:meetclic/domain/entities/menu_tab_up_item.dart';
import 'package:meetclic/presentation/filters/widgets/custom_filter_group.dart';
import 'package:meetclic/presentation/filters/widgets/custom_slider.dart';
import 'package:meetclic/presentation/filters/widgets/custom_section_title.dart';
import 'package:meetclic/presentation/filters/widgets/atoms/custom_switch_tile.dart';
import 'package:meetclic/presentation/filters/widgets/molecules/custom_radio_list.dart';

class ProjectLakePage extends StatefulWidget {
  final String title;
  final List<MenuTabUpItem> itemsStatus;
  const ProjectLakePage({
    super.key,
    required this.title,
    required this.itemsStatus,
  });

  @override
  State<ProjectLakePage> createState() => _ProjectLakePageState();
}

class _ProjectLakePageState extends State<ProjectLakePage> {
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
            children:[],
          ),
        ),


      ),
    );
  }
}
