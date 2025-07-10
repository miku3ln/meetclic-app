import 'package:flutter/material.dart';

void main() => runApp(const DuolingoMockApp());

class DuolingoMockApp extends StatelessWidget {
  const DuolingoMockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Duolingo UI',
      theme: ThemeData.dark(),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 0;

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  void _showModuleOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1C22),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                'Module Options',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              SizedBox(height: 12),
              ListTile(
                leading: Icon(Icons.info, color: Colors.white),
                title: Text('View Details', style: TextStyle(color: Colors.white)),
              ),
              ListTile(
                leading: Icon(Icons.lock_open, color: Colors.white),
                title: Text('Unlock Unit', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      },
    );
  }

  void _navigateToScreen(String screenName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FullScreenPage(title: screenName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFF0F1117),
      drawer: Drawer(
        backgroundColor: const Color(0xFF1A1C22),
        child: ListView(
          padding: EdgeInsets.zero,
          children: const [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.deepPurple),
              child: Text('Unit Menu', style: TextStyle(color: Colors.white, fontSize: 18)),
            ),
            ListTile(
              leading: Icon(Icons.play_arrow, color: Colors.white),
              title: Text('Start Lesson', style: TextStyle(color: Colors.white)),
            ),
            ListTile(
              leading: Icon(Icons.history, color: Colors.white),
              title: Text('Progress', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(Icons.flag, color: Colors.white),
                  Row(
                    children: const [
                      Icon(Icons.local_fire_department, color: Colors.orange),
                      SizedBox(width: 4),
                      Text('5', style: TextStyle(color: Colors.white)),
                      SizedBox(width: 16),
                      Icon(Icons.diamond, color: Colors.cyan),
                      SizedBox(width: 4),
                      Text('2480', style: TextStyle(color: Colors.white)),
                      SizedBox(width: 16),
                      Icon(Icons.emoji_events, color: Colors.purpleAccent),
                    ],
                  )
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                      child: const Text(
                        'SECTION 1, UNIT 9\nTell time',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _showModuleOptions,
                    child: const Icon(Icons.menu, color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {},
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Icon(Icons.circle, size: 90, color: Colors.black26),
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                          child: const Icon(Icons.star, color: Colors.white, size: 40),
                        ),
                        Positioned(
                          top: 4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.deepPurple,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text('START', style: TextStyle(fontSize: 12)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('More content below...', style: TextStyle(color: Colors.white38)),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF1A1C22),
        selectedItemColor: Colors.yellow,
        unselectedItemColor: Colors.grey,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
          final screenNames = ['Home', 'Language', 'Exercise', 'Store', 'Profile', 'More'];
          _navigateToScreen(screenNames[index]);
        },
        items: const [
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

class FullScreenPage extends StatelessWidget {
  final String title;

  const FullScreenPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color(0xFF1A1C22),
      ),
      body: Center(
        child: Text(
          '$title Screen',
          style: const TextStyle(fontSize: 24, color: Colors.white),
        ),
      ),
    );
  }
}
