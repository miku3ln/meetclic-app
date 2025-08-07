import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:meetclic/domain/entities/menu_tab_up_item.dart';
import 'package:meetclic/shared/models/app_config.dart';
import 'package:meetclic/shared/utils/deep_link_type.dart';
import 'package:meetclic/shared/localization/app_localizations.dart';
import 'package:meetclic/aplication/services/access_manager_service.dart';
import 'package:meetclic/infrastructure/deep_links/deep_link_handler.dart';

import 'package:meetclic/presentation/pages/full_screen_page.dart';
import 'package:meetclic/presentation/pages/home/home_infinity.dart';
import 'package:meetclic/presentation/pages/profile_page.dart';
import 'package:meetclic/presentation/pages/rive-example/vehicles_page.dart';
import 'package:meetclic/presentation/pages/business_map_page.dart';

import 'package:meetclic/presentation/widgets/home_drawer_widget.dart';
import 'package:meetclic/presentation/widgets/template/custom_app_bar.dart';

import '../../../../shared/providers_session.dart';
import 'home_page.dart';
import 'package:meetclic/presentation/controllers/menu_tab_up_controller.dart';
import 'package:meetclic/presentation/pages/project_lake_page.dart';


class HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final DeepLinkHandler _deepLinkHandler = DeepLinkHandler();
  StreamSubscription<Uri>? _linkSubscription;

  int _currentIndex = 0;
  DeepLinkInfo? _pendingDeepLink;

  late AppConfig config;
  late AccessManagerService accessManager;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupDependencies();
      _setupListeners();
      _handleInitialLink();
    });
  }

  void _setupDependencies() {
    accessManager = AccessManagerService(context);
  }

  List<Widget> _buildScreens(SessionService session) {
    config = Provider.of<AppConfig>(context, listen: false);
    final menuItems = MenuTabUpController.buildMenu(
      context: context,
      config: config,
      session: session,
      setFlagCallback: setState,
    );
    var pages = [
      _buildHomeContent(menuItems),
      BusinessMapPage(info: _pendingDeepLink, itemsStatus: menuItems),
      FullScreenPage(
        title: AppLocalizations.of(context).translate('pages.shop'),
        itemsStatus: menuItems,
      ),
      VehiclesScreenPage(
        title: AppLocalizations.of(context).translate('pages.aboutUs'),
        itemsStatus: menuItems,
      ),
      ProjectLakePage(
        title: AppLocalizations.of(context).translate('pages.projects'),
        itemsStatus: menuItems,

      ),
    ];
    if (!session.isLoggedIn) {
      pages.add(
        ProfilePage(
          title: AppLocalizations.of(context).translate('pages.profile'),
          itemsStatus: menuItems,
        ),
      );
    }
    return pages;
  }

  void _setupListeners() {
    _linkSubscription = _deepLinkHandler.uriLinkStream.listen(
      (uri) => _handleDeepLink(uri),
      onError: (err) => debugPrint('❌ Error en uriLinkStream: $err'),
    );
  }

  Future<void> _handleInitialLink() async {
    final initialUri = await _deepLinkHandler.getInitialLink();
    if (initialUri != null) {
      _handleDeepLink(initialUri);
    }
  }

  void _handleDeepLink(Uri uri) {
    debugPrint("🔗 Link recibido: $uri");
    final info = _deepLinkHandler.parseUri(uri, context);
    if (info != null) {
      Fluttertoast.showToast(
        msg: "Redirigido desde: ${uri.toString()}",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black87,
        textColor: Colors.white,
      );
      if (info.type == DeepLinkType.businessDetails) {
        setState(() {
          _pendingDeepLink = info;
          _currentIndex = 1; // Mapa
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

  Widget _buildHomeContent(List<MenuTabUpItem> menuItems) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: AppLocalizations.of(context).translate('pages.home'),
        items: menuItems,
      ),
      body: const HomeScrollView(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appLocalizations = AppLocalizations.of(context);

    return Consumer<SessionService>(
      builder: (context, session, _) {
        final screens = _buildScreens(session);
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
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events),
            label: appLocalizations.translate('pages.projects'),
          ),
        ];
        if (!session.isLoggedIn) {
          itemsMenu.add(
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: appLocalizations.translate('pages.profile'),
            ),
          );
        }

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: theme.scaffoldBackgroundColor,
          drawer: const HomeDrawerWidget(),
          body: screens[_currentIndex],
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
      },
    );
  }
}
