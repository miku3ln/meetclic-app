import 'package:flutter/material.dart';
import 'package:meetclic/shared/localization/app_localizations.dart';
import 'package:meetclic/domain/entities/business_data.dart';

class ShopBusinessSection extends StatelessWidget {

  final BusinessData businessManagementData;
  const ShopBusinessSection({super.key, required this.businessManagementData});
  @override
  Widget build(BuildContext context) {
    final translationApi=AppLocalizations.of(context);
    return  Center(child: Text(translationApi.translate('pages.shop'), style: TextStyle(fontSize: 20)));
  }
}