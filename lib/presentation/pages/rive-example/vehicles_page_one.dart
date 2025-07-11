import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart';
import '../../../domain/entities/status_item.dart';
import '../../../presentation/widgets/template/custom_app_bar.dart';

class VehiclesScreenPage extends StatefulWidget {
  final String title;
  final List<StatusItem> itemsStatus;

  const VehiclesScreenPage({
    super.key,
    required this.title,
    required this.itemsStatus,
  });

  @override
  State<VehiclesScreenPage> createState() => _VehiclesScreenPageState();
}

class _VehiclesScreenPageState extends State<VehiclesScreenPage> {
  Artboard? _riveArtboard;
  late RiveAnimationController _idleController;
  late RiveAnimationController _bounceController;
  bool _isIdle = true;
  bool _isPlaying = true;

  // Layout config
  BoxFit _fit = BoxFit.cover;
  Alignment _alignment = Alignment.center;
  Color _backgroundColor = Colors.pink.shade400;

  @override
  void initState() {
    super.initState();
    _loadRiveFile();
  }

  Future<void> _loadRiveFile() async {
    final data = await rootBundle.load('assets/vehicles.riv');
    final file = RiveFile.import(data);
    final artboard = file.mainArtboard;

    _idleController = SimpleAnimation('idle');
    _bounceController = SimpleAnimation('bounce', autoplay: false);

    artboard.addController(_idleController);
    artboard.addController(_bounceController);

    _bounceController.isActive = false;

    setState(() {
      _riveArtboard = artboard;
    });
  }

  void _switchAnimation(String name) {
    if (name == 'idle') {
      _idleController.isActive = true;
      _bounceController.isActive = false;
      _isIdle = true;
    } else {
      _idleController.isActive = false;
      _bounceController.isActive = true;
      _isIdle = false;
    }
  }

  void _togglePlayPause() {
    setState(() {
      _idleController.isActive = !_idleController.isActive;
      _bounceController.isActive = !_bounceController.isActive;
      _isPlaying = !_isPlaying;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(title: widget.title, items: widget.itemsStatus),
      body: Column(
        children: [
          const SizedBox(height: 12),
          Expanded(
            child: Container(
              color: _backgroundColor,
              child: Center(
                child: _riveArtboard == null
                    ? const CircularProgressIndicator()
                    : Rive(
                  artboard: _riveArtboard!,
                  fit: _fit,
                  alignment: _alignment,
                ),
              ),
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: [
                ElevatedButton(
                  onPressed: () => _switchAnimation('idle'),
                  child: const Text('Idle'),
                ),
                ElevatedButton(
                  onPressed: () => _switchAnimation('bounce'),
                  child: const Text('Bounce'),
                ),
                ElevatedButton(
                  onPressed: _togglePlayPause,
                  child: Text(_isPlaying ? 'Pausar' : 'Reanudar'),
                ),
                DropdownButton<BoxFit>(
                  value: _fit,
                  onChanged: (value) => setState(() => _fit = value!),
                  items: BoxFit.values
                      .map((fit) => DropdownMenuItem(
                    value: fit,
                    child: Text(fit.name.toUpperCase()),
                  ))
                      .toList(),
                ),
                DropdownButton<Alignment>(
                  value: _alignment,
                  onChanged: (value) => setState(() => _alignment = value!),
                  items: const [
                    DropdownMenuItem(
                        value: Alignment.center, child: Text('Centro')),
                    DropdownMenuItem(
                        value: Alignment.topCenter, child: Text('Arriba')),
                    DropdownMenuItem(
                        value: Alignment.bottomCenter, child: Text('Abajo')),
                    DropdownMenuItem(
                        value: Alignment.centerLeft, child: Text('Izquierda')),
                    DropdownMenuItem(
                        value: Alignment.centerRight, child: Text('Derecha')),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _backgroundColor = _backgroundColor == Colors.pink.shade400
                          ? Colors.transparent
                          : Colors.pink.shade400;
                    });
                  },
                  child: const Text('Fondo: Cambiar'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
