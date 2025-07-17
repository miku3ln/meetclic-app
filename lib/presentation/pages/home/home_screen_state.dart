import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:meetclic/presentation/pages/rive-example/vehicles_page.dart';
import 'package:provider/provider.dart';
import 'package:app_links/app_links.dart';

import 'package:meetclic/domain/entities/module_model.dart';
import 'package:meetclic/domain/entities/menu_tab_up_item.dart';
import 'package:meetclic/shared/models/app_config.dart';
import 'package:meetclic/shared/utils/deep_link_type.dart';
import 'package:meetclic/shared/localization/app_localizations.dart';

import 'package:meetclic/presentation/widgets/home_drawer_widget.dart';
import 'package:meetclic/presentation/widgets/template/custom_app_bar.dart';
import 'package:meetclic/presentation/pages/full_screen_page.dart';
import 'package:meetclic/presentation/pages/profile_page.dart';
import 'modals/show_register_user.dart';
import 'modals/show_view_components.dart';

import 'package:meetclic/presentation/pages/business_map_page.dart';
import 'modals/top_modal.dart';
import 'modals/language_modal.dart';
import 'home_page.dart';
import 'package:meetclic/presentation/widgets/start_button_widget.dart';

import 'package:meetclic/shared/models/api_response.dart';

import 'package:meetclic/presentation/pages/home/home_infinity.dart';
import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final AppLinks _appLinks = AppLinks();

  StreamSubscription<Uri>? _linkSubscription;
  int _currentIndex = 0;
  ModuleModel? _selectedModule;

  DeepLinkInfo? _pendingDeepLink;
  List<MenuTabUpItem> menuTabUpItems = [];
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);
  String status = 'No autenticado';

  Future<ApiResponse<Map<String, dynamic>>> loginWithGoogle() async {
    try {
      print('sendTokenToBackend---------------------------');

      final account = await _googleSignIn.signIn();
      if (account == null) {
        final message = 'Cancelado por el usuario';
        print('loginWithGoogle: ${message}');
        return ApiResponse(success: false, message: message, data: null);
      }

      final auth = await account.authentication;
      final idToken = auth.idToken;

      if (idToken == null) {
        final message = 'Error: idToken es null';
        print('loginWithGoogle: ${message}');
        return ApiResponse(success: false, message: message, data: null);
      }

      // ✅ Retorna la respuesta del backend como ApiResponse
      return await sendTokenToBackend(idToken);
    } catch (e) {
      final message = 'Error: $e';
      print('loginWithGoogle: ${message}');
      return ApiResponse(success: false, message: message, data: null);
    }

    print('loginWithGoogle--------------------------- ERORR');
  }

  Future<ApiResponse<Map<String, dynamic>>> sendTokenToBackend(
    String idToken,
  ) async {
    try {
      final url = Uri.parse('https://tudominio.com/api/auth/google-mobile');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id_token': idToken}),
      );

      // ✅ Manejo de errores HTTP
      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Éxito: procesar normalmente
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final message = 'Ok';
        print('sendTokenToBackend---------------------------: ${message}');
        return ApiResponse.fromJson(
          jsonResponse,
          (data) => data as Map<String, dynamic>,
        );
      } else {
        // ⚠️ Error HTTP: devolver código y respuesta cruda del backend
        String backendMessage = response.body;
        try {
          // Intentar extraer un mensaje legible del backend si está en formato JSON
          final Map<String, dynamic> errorResponse = jsonDecode(response.body);
          backendMessage = errorResponse['message'] ?? backendMessage;
        } catch (_) {
          // Ignorar si no es JSON
        }
        final message = 'Error ${response.statusCode}: $backendMessage';
        print('sendTokenToBackend: ${message}');
        return ApiResponse(success: false, message: message, data: null);
      }
    } catch (e) {
      // ❌ Errores de conexión, timeout, formato inválido, etc.
      final message = 'Error de red o inesperado: $e';
      print('sendTokenToBackend: ${message}');
      return ApiResponse(success: false, message: message, data: null);
    }
  }

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
            asset: 'assets/appbar/yapitas.png',
            number: 5,
            onTap: () => showViewComponents(context, (formData) {
              // Aquí recibes el Map<String, String> con los datos ingresados
              print('🚀 Datos capturados del modal:');
              formData.forEach((key, value) {
                print('$key: $value');
              });

              // Puedes usar formData aquí para cualquier lógica
              // Por ejemplo, enviarlo a un backend o guardarlo en un estado
            }),
          ),
          MenuTabUpItem(
            id: 3,
            name: 'diamante',
            asset: 'assets/appbar/yapitas-premium.png',
            number: 2480,
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
          MenuTabUpItem(
            id: 4,
            name: 'trofeo',
            asset: 'assets/appbar/trophy-two.png',
            number: 2,
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
          MenuTabUpItem(
            id: 5,
            name: 'cesta',
            asset: 'assets/appbar/basket.png',
            number: 4,
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
    final appLocalizations = AppLocalizations.of(context);

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
        items: [
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
            icon: Icon(Icons.person),
            label: appLocalizations.translate('pages.profile'),
          ),
        ],
      ),
    );
  }
}
