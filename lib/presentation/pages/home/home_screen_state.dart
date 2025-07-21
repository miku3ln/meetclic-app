import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:meetclic/presentation/pages/rive-example/vehicles_page.dart';
import 'package:provider/provider.dart';
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
import 'package:meetclic/domain/services/session_service.dart';
import 'package:meetclic/aplication/services/access_manager_service.dart';
class HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;
  int _currentIndex = 0;
  DeepLinkInfo? _pendingDeepLink;
  List<MenuTabUpItem> menuTabUpItems = [];
  @override
  void initState() {
    var yapitasCount = 0;
    var yapitasPremiumCount = 0;
    var trofeosCount = 0;
    var cestaCount = 0;
    var idiomaCount = 3;
    if (SessionService().isLoggedIn) {
      yapitasCount = 100;
      yapitasPremiumCount = 20;
      trofeosCount = 3;
      cestaCount = 0;
    }
    super.initState();
    final config = Provider.of<AppConfig>(context, listen: false);
    final currentLocale = config.locale.languageCode;
    final accessManager = AccessManagerService(context);
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
    var menuTabUpItemsCurrent = [
      itemLanguage,
      MenuTabUpItem(
        id: 2,
        name: 'fuego',
        asset: 'assets/appbar/yapitas.png',
        number: yapitasCount,
        onTap: () async {
          final result = await accessManager.handleAccess(() async {
            showViewComponents(context, (formData) {
              print('🚀 Datos recibidos: $formData');
            });
          });
          if (result.success) {
            print('✅ Acceso concedido o registrado');
          } else {
            print('❌ Error: ${result.message}');
          }
        },
      ),
      MenuTabUpItem(
        id: 3,
        name: 'diamante',
        asset: 'assets/appbar/yapitas-premium.png',
        number: yapitasPremiumCount,
        onTap: () async {
          final result = await accessManager.handleAccess(() async {
            showViewComponents(context, (formData) {
              print('🚀 Datos recibidos: $formData');
            });
          });
          if (result.success) {
            print('✅ Acceso concedido o registrado');
          } else {
            print('❌ Error: ${result.message}');
          }
        },
      ),
      MenuTabUpItem(
        id: 4,
        name: 'trofeo',
        asset: 'assets/appbar/trophy-two.png',
        number: trofeosCount,
        onTap: () async {
          final result = await accessManager.handleAccess(() async {
            showViewComponents(context, (formData) {
              print('🚀 Datos recibidos: $formData');
            });
          });
          if (result.success) {
            print('✅ Acceso concedido o registrado');
          } else {
            print('❌ Error: ${result.message} trofeo');
          }
        },
      ),
      MenuTabUpItem(
        id: 5,
        name: 'cesta',
        asset: 'assets/appbar/basket.png',
        number: cestaCount,
        onTap: () => showTopModal(
          context: context,
          title: "¡Bienvenido!",
          contentText: "Gracias por unirte a nuestra aplicación.",
          buttonText: "Aceptar",
          onButtonPressed: () {
            print("Botón presionado");
          },
          heightPercentage: 0.25,
          backgroundColor: Colors.white,
          titleStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
          contentStyle: TextStyle(fontSize: 16, color: Colors.black87),
          buttonStyle: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            minimumSize: Size.fromHeight(50),
            textStyle: TextStyle(fontSize: 18),
          ),
        ),
      ),
    ];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        menuTabUpItems = menuTabUpItemsCurrent;
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

    final session = Provider.of<SessionService>(context);  // ✅ Reactivo: escucha cambios

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
      if (session.isLoggedIn)   // ✅ Cambio reactivo automático
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
}
