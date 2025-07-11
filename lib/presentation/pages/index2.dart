import 'package:flutter/material.dart';
import 'package:meetclic/domain/entities/module_model.dart';
import 'package:meetclic/presentation/widgets/home_drawer_widget.dart';
import 'package:meetclic/presentation/widgets/home/header_widget.dart';
import 'package:meetclic/presentation/widgets/module_selector_widget.dart';
import 'package:meetclic/presentation/widgets/start_button_widget.dart';
import 'full_screen_page.dart';
import 'business_map_page.dart';
import '../../../presentation/widgets/template/custom_app_bar.dart';
import '../../../domain/entities/status_item.dart';
import '../../../presentation/pages/rive-example/vehicles_page.dart';
import 'deep_link_page.dart';
import 'package:fluttertoast/fluttertoast.dart';
class HomeScreen extends StatefulWidget {
  final List<ModuleModel> modules;
  final List<StatusItem> itemsStatus;

  const HomeScreen({
    super.key,
    required this.modules,
    required this.itemsStatus,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 0;
  ModuleModel? _selectedModule;

  void _openDrawer() => _scaffoldKey.currentState?.openDrawer();

  void _showModuleOptions() {
    final theme = Theme.of(context);
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
            Text('Module Options', style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            ListTile(
              leading: Icon(Icons.info, color: theme.colorScheme.onBackground),
              title: Text('View Details', style: theme.textTheme.bodyMedium),
            ),
            ListTile(
              leading: Icon(
                Icons.lock_open,
                color: theme.colorScheme.onBackground,
              ),
              title: Text('Unlock Unit', style: theme.textTheme.bodyMedium),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> get _screens => [
    _buildHomeContent(),
    BusinessMapPage(),
    FullScreenPage(title: 'Exercise', itemsStatus: widget.itemsStatus),
    FullScreenPage(title: 'Store', itemsStatus: widget.itemsStatus),
    FullScreenPage(title: 'Profile', itemsStatus: widget.itemsStatus),
    VehiclesScreenPage(title: 'More', itemsStatus: widget.itemsStatus),
  ];

  SafeArea _get() {
    final theme = Theme.of(context);
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),
            const HeaderWidget(),
            const SizedBox(height: 10),
            _buildUnitBanner(theme),
            const SizedBox(height: 10),
            StartButtonWidget(),
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
    );
  }

  Widget _buildHomeContent() {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(title: 'Inicio', items: widget.itemsStatus),
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
        items:  [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.language), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: ''),
        ],
      ),
    );
  }
}
