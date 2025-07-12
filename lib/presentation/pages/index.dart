import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:app_links/app_links.dart';

import 'package:meetclic/domain/entities/module_model.dart';
import 'package:meetclic/domain/entities/status_item.dart';
import 'package:meetclic/presentation/pages/rive-example/vehicles_page.dart';
import 'package:meetclic/presentation/widgets/home_drawer_widget.dart';
import 'package:meetclic/presentation/widgets/home/header_widget.dart';
import 'package:meetclic/presentation/widgets/module_selector_widget.dart';
import 'package:meetclic/presentation/widgets/start_button_widget.dart';
import '../../../presentation/widgets/template/custom_app_bar.dart';

import 'full_screen_page.dart';
import 'business_map_page.dart';
import '../../../shared/utils/deep_link_type.dart';
import '../../shared/localization/app_localizations.dart';
import 'package:meetclic/domain/entities/menu_tab_up_item.dart';
import 'package:provider/provider.dart';
import 'package:meetclic/shared/models/app_config.dart';

class HomeScreen extends StatefulWidget {
  final List<ModuleModel> modules;

  const HomeScreen({super.key, required this.modules});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        menuTabUpItems = [
          MenuTabUpItem(
            name: 'idioma',
            asset: 'assets/flags/es.png',
            number: 3,
            onTap: () => showTopLanguageModal(
              context,
              (newLocale) => config.setLocale(Locale(newLocale)
              ),
            ),
          ),
          MenuTabUpItem(
            name: 'fuego',
            asset: 'assets/appbar/fire.jpg',
            number: 5,
            onTap: () => showTopModal(context, 'Fuego'),
          ),
          MenuTabUpItem(
            name: 'diamante',
            asset: 'assets/appbar/diamond.jpg',
            number: 2480,
            onTap: () => showTopModal(context, 'Diamantes'),
          ),
          MenuTabUpItem(
            name: 'trofeo',
            asset: 'assets/appbar/trophy.jpg',
            number: 2,
            onTap: () => showTopModal(context, 'Trofeos'),
          ),
          MenuTabUpItem(
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
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  void _openDrawer() => _scaffoldKey.currentState?.openDrawer();

  void showTopModal(BuildContext context, String title) {
    final overlay = Overlay.of(context);
    final screenSize = MediaQuery.of(context).size;
    final modalHeight = screenSize.height * 0.3;

    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) => Stack(
        children: [
          // Fondo oscuro semitransparente (opcional)
          GestureDetector(
            onTap: () => entry.remove(),
            child: Container(
              width: screenSize.width,
              height: screenSize.height,
              color: Colors.black.withOpacity(0.4),
            ),
          ),

          // Modal en la parte superior
          Positioned(
            top: 73,
            left: 0,
            right: 0,
            child: Material(
              color: Colors.transparent,
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 20),
                    width: screenSize.width,
                    height: modalHeight,
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text("Aquí iría el contenido del modal..."),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: () => entry.remove(),
                          child: const Text("Cerrar"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    overlay.insert(entry);
  }

  void showTopLanguageModal(BuildContext context, Function(String) onChanged) {
    final overlay = Overlay.of(context);
    final screenSize = MediaQuery.of(context).size;
    final modalHeight = screenSize.height * 0.3;
    final colorScheme = Theme.of(context).colorScheme;
    final config = Provider.of<AppConfig>(context, listen: false);
    final currentLocale = config.locale.languageCode;

    final Map<String, String> languages = {
      'es': 'Español',
      'en': 'Ingles',
      'it': 'Kichwa', // Ejemplo simbólico
    };

    final Map<String, String> flags = {
      'es': 'assets/flags/es.png',
      'en': 'assets/flags/en.png',
      'it': 'assets/flags/ki.png',
    };

    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) => Stack(
        children: [
          GestureDetector(
            onTap: () => entry.remove(),
            child: Container(
              width: screenSize.width,
              height: screenSize.height,
              color: Colors.black.withOpacity(0.4),
            ),
          ),
          Positioned(
            top: 73,
            left: 0,
            right: 0,
            child: Material(
              color: Colors.transparent,
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 20),
                    width: screenSize.width,
                    height: modalHeight,
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Selecciona un idioma",
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(height: 12),
                        Expanded(
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: languages.entries.map((entry) {
                              final isSelected = entry.key == currentLocale;
                              return GestureDetector(
                                onTap: () {
                                  onChanged(entry.key);
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(right: 12),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    border: isSelected
                                        ? Border.all(
                                            color: Colors.lightBlueAccent,
                                            width: 3,
                                          )
                                        : null,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        flags[entry.key]!,
                                        width: 50,
                                        height: 35,
                                        fit: BoxFit.contain,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        entry.value,
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    overlay.insert(entry);
  }

  void _showModuleOptions() {
    final theme = Theme.of(context);
    final colorScheme = Theme.of(context).colorScheme;

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
                style: TextStyle(color: colorScheme.primary, fontSize: 18),
              ),
            ),
            ListTile(
              leading: Icon(Icons.lock_open, color: colorScheme.secondary),
              title: Text(
                'Unlock Unit',
                style: TextStyle(color: colorScheme.primary, fontSize: 18),
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
