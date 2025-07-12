import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:app_links/app_links.dart';

import 'package:meetclic/domain/entities/module_model.dart';
import 'package:meetclic/domain/entities/menu_tab_up_item.dart';
import 'package:meetclic/shared/models/app_config.dart';
import 'package:meetclic/shared/utils/deep_link_type.dart';
import 'package:meetclic/shared/localization/app_localizations.dart';

import 'package:meetclic/presentation/widgets/home/header_widget.dart';
import 'package:meetclic/presentation/widgets/module_selector_widget.dart';
import 'package:meetclic/presentation/widgets/start_button_widget.dart';
import 'package:meetclic/presentation/widgets/home_drawer_widget.dart';
import 'package:meetclic/presentation/widgets/template/custom_app_bar.dart';
import 'package:meetclic/presentation/pages/full_screen_page.dart';
import 'package:meetclic/presentation/pages/business_map_page.dart';
import 'package:meetclic/presentation/pages/rive-example/vehicles_page.dart';
import 'modals/top_modal.dart';
import 'modals/language_modal.dart';
import 'home_page.dart';

class HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final AppLinks _appLinks = AppLinks();

  StreamSubscription<Uri>? _linkSubscription;
  int _currentIndex = 0;
  ModuleModel? _selectedModule;

  DeepLinkInfo? _pendingDeepLink;
  List<MenuTabUpItem> menuTabUpItems = [];

  @override
  void initState() {
    super.initState();
    final config = Provider.of<AppConfig>(context, listen: false);
    // Post-frame callback
    final currentLocale = config.locale.languageCode;
    final itemLanguage = MenuTabUpItem(
      id: 1,
      name: 'idioma',
      asset: 'assets/flags/$currentLocale.png',
      number: 3,
      onTap: () => showTopLanguageModal(
        context,
        (newLocale) => config.setLocale(Locale(newLocale)),
        menuTabUpItems,
        setState,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        menuTabUpItems = [
          itemLanguage,
          MenuTabUpItem(
            id: 2,
            name: 'fuego',
            asset: 'assets/appbar/fire.jpg',
            number: 5,
            onTap: () => showTopModal(context, 'Fuego'),
          ),
          MenuTabUpItem(
            id: 3,
            name: 'diamante',
            asset: 'assets/appbar/diamond.jpg',
            number: 2480,
            onTap: () => showTopModal(context, 'Diamantes'),
          ),
          MenuTabUpItem(
            id: 4,
            name: 'trofeo',
            asset: 'assets/appbar/trophy.jpg',
            number: 2,
            onTap: () => showTopModal(context, 'Trofeos'),
          ),
          MenuTabUpItem(
            id: 5,
            name: 'cesta',
            asset: 'assets/appbar/basket.jpg',
            number: 4,
            onTap: () => showTopModal(context, 'Cesta'),
          ),
        ];
      });
    });

    _initDeepLinkListener();
  }

  Future<void> _initDeepLinkListener() async {
    try {
      final Uri? initialUri = await _appLinks.getInitialAppLink();
      if (initialUri != null) _handleDeepLink(initialUri);
    } catch (e) {
      debugPrint('❌ Error obteniendo link inicial: $e');
    }

    _linkSubscription = _appLinks.uriLinkStream.listen(
      (Uri uri) => _handleDeepLink(uri),
      onError: (err) => debugPrint('❌ Error en uriLinkStream: $err'),
    );
  }

  void _handleDeepLink(Uri uri) {
    debugPrint("🔗 Link recibido: $uri");

    final deepLinkInfo = DeepLinkUtils.fromUri(uri);

    if (deepLinkInfo != null) {
      Fluttertoast.showToast(
        msg: "Redirigido desde: ${uri.toString()}",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black87,
        textColor: Colors.white,
      );

      if (deepLinkInfo.type == DeepLinkType.businessDetails) {
        setState(() {
          _pendingDeepLink = deepLinkInfo;
          _currentIndex = 1;
        });
      }
    } else {
      debugPrint("⚠️ DeepLink no reconocido: $uri");
      Fluttertoast.showToast(
        msg: "Enlace no válido o no soportado.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.redAccent,
        textColor: Colors.white,
      );
    }
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  void _openDrawer() => _scaffoldKey.currentState?.openDrawer();

  void _showModuleOptions() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Module Options',
              style: TextStyle(color: colorScheme.primary, fontSize: 18),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: Icon(Icons.info, color: colorScheme.secondary),
              title: Text(
                'View Details',
                style: TextStyle(color: colorScheme.primary),
              ),
            ),
            ListTile(
              leading: Icon(Icons.lock_open, color: colorScheme.secondary),
              title: Text(
                'Unlock Unit',
                style: TextStyle(color: colorScheme.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> get _screens => [
    _buildHomeContent(),
    BusinessMapPage(info: _pendingDeepLink, itemsStatus: menuTabUpItems),
    FullScreenPage(
      title: AppLocalizations.of(context).translate('pages.shop'),
      itemsStatus: menuTabUpItems,
    ),
    FullScreenPage(
      title: AppLocalizations.of(context).translate('pages.aboutUs'),
      itemsStatus: menuTabUpItems,
    ),
    FullScreenPage(
      title: AppLocalizations.of(context).translate('pages.gaming'),
      itemsStatus: menuTabUpItems,
    ),
    VehiclesScreenPage(
      title: AppLocalizations.of(context).translate('pages.projects'),
      itemsStatus: menuTabUpItems,
    ),
  ];
  Widget _buildHomeContent() {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: AppLocalizations.of(context).translate('pages.home'),
        items: menuTabUpItems,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 10),
              const HeaderWidget(),
              const SizedBox(height: 10),
              _buildUnitBanner(theme),
              const SizedBox(height: 10),
              const StartButtonWidget(),
              const SizedBox(height: 20),
              if (widget.modules.isNotEmpty)
                ModuleSelectorWidget(
                  modules: widget.modules,
                  selectedModule: _selectedModule,
                  onModuleChanged: (value) =>
                      setState(() => _selectedModule = value),
                ),
              Text(
                'More content below...',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white38,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUnitBanner(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.redAccent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: _openDrawer,
              child: Text(
                'SECTION 1, UNIT 9\nTell time',
                style: theme.textTheme.bodyMedium?.copyWith(fontSize: 16),
              ),
            ),
          ),
          GestureDetector(
            onTap: _showModuleOptions,
            child: Icon(Icons.menu, color: theme.iconTheme.color),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: theme.scaffoldBackgroundColor,
      drawer: const HomeDrawerWidget(),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: theme.colorScheme.primary,
        selectedItemColor: theme.colorScheme.secondary,
        unselectedItemColor: Colors.white,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.language), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: ''),
        ],
      ),
    );
  }
}
