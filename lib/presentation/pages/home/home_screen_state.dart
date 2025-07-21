import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:meetclic/presentation/pages/rive-example/vehicles_page.dart';
import 'package:app_links/app_links.dart';
import 'package:meetclic/domain/entities/menu_tab_up_item.dart';
import 'package:meetclic/shared/models/app_config.dart';
import 'package:meetclic/shared/utils/deep_link_type.dart';
import 'package:meetclic/shared/localization/app_localizations.dart';
import 'package:meetclic/presentation/widgets/home_drawer_widget.dart';
import 'package:meetclic/presentation/widgets/template/custom_app_bar.dart';
import 'package:meetclic/presentation/pages/full_screen_page.dart';
import 'package:meetclic/presentation/pages/profile_page.dart';
import 'modals/show_view_components.dart';
import 'package:meetclic/presentation/pages/business_map_page.dart';
import 'modals/top_modal.dart';
import 'modals/language_modal.dart';
import 'home_page.dart';
import 'package:meetclic/presentation/pages/home/home_infinity.dart';
import 'package:meetclic/aplication/services/access_manager_service.dart';
import '../../../../shared/providers_session.dart';

class HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;
  int _currentIndex = 0;
  DeepLinkInfo? _pendingDeepLink;
  List<MenuTabUpItem> menuTabUpItems = [];
  late SessionService session;
  late AppConfig config;
  late AccessManagerService accessManager;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      session = Provider.of<SessionService>(context, listen: false);
      config = Provider.of<AppConfig>(context, listen: false);
      accessManager = AccessManagerService(context);
      session.addListener(_initializeMenu);
      _initializeMenu();
      _initDeepLinkListener();
    });
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

  List<Widget> get _screens => [
    _buildHomeContent(),
    BusinessMapPage(info: _pendingDeepLink, itemsStatus: menuTabUpItems),
    FullScreenPage(
      title: AppLocalizations.of(context).translate('pages.shop'),
      itemsStatus: menuTabUpItems,
    ),
    VehiclesScreenPage(
      title: AppLocalizations.of(context).translate('pages.aboutUs'),
      itemsStatus: menuTabUpItems,
    ),
    ProfilePage(
      title: AppLocalizations.of(context).translate('pages.profile'),
      itemsStatus: menuTabUpItems,
    ),
    FullScreenPage(
      title: AppLocalizations.of(context).translate('pages.gaming'),
      itemsStatus: menuTabUpItems,
    ),
  ];

  Widget _buildHomeContent() {
    final theme = Theme.of(context);
    final bodyCurrent2 =
        const HomeScrollView(); // o crea aquí tu widget inicial
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: AppLocalizations.of(context).translate('pages.home'),
        items: menuTabUpItems,
      ),
      body: bodyCurrent2,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appLocalizations = AppLocalizations.of(context);
    final session = Provider.of<SessionService>(
      context,
    ); // ✅ Reactivo: escucha cambios
    final itemsMenu = [
      BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: appLocalizations.translate('pages.home'),
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.language),
        label: appLocalizations.translate('pages.explore'),
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.shopping_bag),
        label: appLocalizations.translate('pages.shop'),
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.emoji_events),
        label: appLocalizations.translate('pages.gaming'),
      ),
      if (session.isLoggedIn) // ✅ Cambio reactivo automático
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: appLocalizations.translate('pages.profile'),
        ),
    ];

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
        items: itemsMenu,
      ),
    );
  }

  void _initializeMenu() {
    final user = session.currentSession;

    final yapitasCount = session.isLoggedIn ? 100 : 0;
    final yapitasPremiumCount = session.isLoggedIn ? 20 : 0;
    final trofeosCount = session.isLoggedIn ? 3 : 0;
    final cestaCount = 0;
    final idiomaCount = 3;

    final currentLocale = config.locale.languageCode;

    final itemLanguage = MenuTabUpItem(
      id: 1,
      name: 'idioma',
      asset: 'assets/flags/$currentLocale.png',
      number: idiomaCount,
      onTap: () => showTopLanguageModal(
        context,
        (newLocale) => config.setLocale(Locale(newLocale)),
        menuTabUpItems,
        setState,
      ),
    );

    final menu = [
      itemLanguage,
      _buildMenuItem('fuego', 'assets/appbar/yapitas.png', yapitasCount),
      _buildMenuItem(
        'diamante',
        'assets/appbar/yapitas-premium.png',
        yapitasPremiumCount,
      ),
      _buildMenuItem('trofeo', 'assets/appbar/trophy-two.png', trofeosCount),
      _buildBasketItem(cestaCount),
    ];

    setState(() {
      menuTabUpItems = menu;
    });
  }

  MenuTabUpItem _buildMenuItem(String name, String asset, int count) {
    return MenuTabUpItem(
      id: name.hashCode,
      name: name,
      asset: asset,
      number: count,
      onTap: () async {
        final result = await accessManager.handleAccess(() async {
          showViewComponents(context, (formData) {
            print('🚀 Datos recibidos: $formData');
          });
        });

        if (result.success) {
          print('✅ Acceso concedido o registrado ($name)');
        } else {
          print('❌ Error: ${result.message} ($name)');
        }
      },
    );
  }

  MenuTabUpItem _buildBasketItem(int count) {
    return MenuTabUpItem(
      id: 5,
      name: 'cesta',
      asset: 'assets/appbar/basket.png',
      number: count,
      onTap: () => showTopModal(
        context: context,
        title: "¡Bienvenido!",
        contentText: "Gracias por unirte a nuestra aplicación.",
        buttonText: "Aceptar",
        onButtonPressed: () {},
        heightPercentage: 0.25,
        backgroundColor: Colors.white,
        titleStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
        contentStyle: const TextStyle(fontSize: 16, color: Colors.black87),
        buttonStyle: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          minimumSize: const Size.fromHeight(50),
          textStyle: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
