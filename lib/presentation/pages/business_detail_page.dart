import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:meetclic/domain/entities/business_data.dart';
import 'package:meetclic/domain/models/api_response_model.dart';
import 'package:meetclic/domain/models/business_model.dart';
import 'package:meetclic/domain/usecases/get_nearby_businesses_usecase.dart';
import 'package:meetclic/infrastructure/repositories/implementations/business_repository_impl.dart';
import 'package:meetclic/shared/localization/app_localizations.dart';

import '../../../presentation/widgets/template/custom_app_bar.dart';
import '../widgets/home-business/gamification_business_section.dart';
import '../widgets/home-business/home_business_section.dart';
import '../widgets/home-business/news_business_section.dart';
import '../widgets/home-business/shop_business_section.dart';

Future<ApiResponseModel<List<BusinessModel>>> _loadBusinessesDetails(
  businessId,
) async {
  final useCase = BusinessesDetailsUseCase(
    repository: BusinessDetailsRepositoryImpl(),
  );

  final response = await useCase.execute(businessId: businessId);
  return response;
}

class BusinessDetailPage extends StatefulWidget {
  final int businessId;

  const BusinessDetailPage({super.key, required this.businessId});

  @override
  State<BusinessDetailPage> createState() => _BusinessDetailPageState();
}

class _BusinessDetailPageState extends State<BusinessDetailPage> {
  late BusinessModel business; // Se usará para almacenar los datos actualizados
  late BusinessData businessData;
  late List<Widget> _pages;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    business = BusinessModel.empty(widget.businessId);
    // inicializamos con el business recibido
    _loadData(); // luego lo actualizamos
  }

  Future<void> _loadData() async {
    businessData = BusinessData(business: business);
    _pages = [
      HomeBusinessSection(businessManagementData: businessData),
      ShopBusinessSection(businessManagementData: businessData),
      NewsBusinessSection(businessManagementData: businessData),
      GamificationBusinessSection(businessManagementData: businessData),
    ];

    setState(() {});
  }

  void _onNavTap(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appLocalizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: CustomAppBar(title: '', items: []),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(child: Stack(children: [_pages[_selectedIndex]])),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavIcon(
                icon: Icons.info_outline,
                index: 0,
                label: appLocalizations.translate(
                  'pages.businessSection.information',
                ),
              ),
              _buildNavIcon(
                icon: Icons.shopping_bag,
                index: 1,
                label: appLocalizations.translate('pages.businessSection.shop'),
              ),
              const SizedBox(width: 40),
              _buildNavIcon(
                icon: Icons.newspaper,
                index: 2,
                label: appLocalizations.translate('pages.businessSection.news'),
              ),
              _buildNavIcon(
                icon: Icons.emoji_events,
                index: 3,
                label: appLocalizations.translate(
                  'pages.businessSection.gaming',
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: theme.colorScheme.primary,
        child: const Icon(Icons.add_business),
        onPressed: () {
          Fluttertoast.showToast(
            msg: "Empresa agregada a tu lista 💼",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.black87,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildNavIcon({
    required IconData icon,
    required int index,
    required String label,
  }) {
    final theme = Theme.of(context);
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => _onNavTap(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected
                ? theme.colorScheme.secondary
                : theme.colorScheme.onPrimary,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isSelected
                  ? theme.colorScheme.secondary
                  : theme.colorScheme.onPrimary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
