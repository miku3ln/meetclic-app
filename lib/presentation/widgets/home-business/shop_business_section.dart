import 'package:flutter/material.dart';
import 'package:meetclic/shared/localization/app_localizations.dart';

class ShopBusinessSection extends StatelessWidget {
  const ShopBusinessSection();

  @override
  Widget build(BuildContext context) {
    final translationApi=AppLocalizations.of(context);
    return  Center(child: Text(translationApi.translate('pages.shop'), style: TextStyle(fontSize: 20)));
  }
}