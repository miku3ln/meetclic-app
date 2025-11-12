import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geo;

// usa tus rutas reales según colocaste el plugin en tu monorepo
import 'lib/management_plugins_location.dart';
import 'lib/src/data/repositories/device_sensors_repository_impl.dart';

class LocationDemoPage extends StatefulWidget {
  const LocationDemoPage({super.key});
  @override
  State<LocationDemoPage> createState() => _LocationDemoPageState();
}

class _LocationDemoPageState extends State<LocationDemoPage>
    with WidgetsBindingObserver {
  late final DeviceSensorsRepository _repo;
  late final GetCurrentLocation _getCurrentLocation;
  late final EnsureLocationPermission _ensurePerm;
  late final CheckLocationServiceEnabled _checkService;
  late final IsAccelerometerAvailable _checkAccel;
  late final AccelerometerStream _accStreamUC;
  late final UserAccelerometerStream _userAccStreamUC;

  StreamSubscription? _accSub, _userAccSub;
  StreamSubscription<geo.ServiceStatus>? _locServiceSub;

  String _status = 'Inicializando...';
  DeviceLocation? _loc;

  bool _gpsServiceEnabled = false; // servicio (GPS)
  bool _gpsPermissionOk = false; // permiso app
  bool _accelerometerAvailable = false;

  ({double x, double y, double z})? _lastAcc, _lastUserAcc;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _repo = DeviceSensorsRepositoryImpl();
    _getCurrentLocation = GetCurrentLocation(_repo);
    _ensurePerm = EnsureLocationPermission(_repo);
    _checkService = CheckLocationServiceEnabled(_repo);
    _checkAccel = IsAccelerometerAvailable(_repo);
    _accStreamUC = AccelerometerStream(_repo);
    _userAccStreamUC = UserAccelerometerStream(_repo);

    _bootstrap();
    _listenLocationService(); // escucha ON/OFF del GPS en vivo
  }

  /// Carga estados iniciales
  Future<void> _bootstrap() async {
    await _refreshGpsStates();
    await _refreshAccelState();
    _syncStatusText();
  }

  /// Listener del estado del servicio de ubicación (enabled/disabled)
  void _listenLocationService() {
    _locServiceSub = geo.Geolocator.getServiceStatusStream().listen((
      status,
    ) async {
      final enabled = (status == geo.ServiceStatus.enabled);
      // Cuando cambia el servicio, revalidamos permisos también
      final permOk = await _ensurePerm();

      if (!mounted) return;
      setState(() {
        _gpsServiceEnabled = enabled;
        _gpsPermissionOk = permOk;
      });
      _syncStatusText();
    });
  }

  /// Se llama cuando la app vuelve a primer plano (ideal para detectar cambios en ajustes)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Revalida servicio/permiso/accel sin que el usuario toque nada
      _bootstrap();
    }
    super.didChangeAppLifecycleState(state);
  }

  Future<void> _refreshGpsStates() async {
    final serviceOn = await _checkService();
    final permOk = await _ensurePerm();
    if (!mounted) return;
    setState(() {
      _gpsServiceEnabled = serviceOn;
      _gpsPermissionOk = permOk;
    });
  }

  Future<void> _refreshAccelState() async {
    final accelAvail = await _checkAccel();
    if (!mounted) return;
    setState(() => _accelerometerAvailable = accelAvail);
  }

  void _syncStatusText() {
    setState(() {
      _status =
          'GPS: ${_gpsServiceEnabled ? 'habilitado' : 'deshabilitado'} | '
          'Permiso: ${_gpsPermissionOk ? 'otorgado' : 'pendiente'} | '
          'Acelerómetro: ${_accelerometerAvailable ? 'disponible' : 'no disponible'}';
    });
  }

  // Guiado para activar GPS y permiso (abre ajustes y al volver revalida solo)
  Future<void> _ensureGpsReady() async {
    // Si el servicio está apagado, abrimos ajustes de ubicación
    final serviceOn = await _checkService();
    if (!serviceOn) {
      await _repo.openLocationSettings();
      return; // al volver a la app, didChangeAppLifecycleState(resumed) revalida solo
    }
    // Si el servicio ya está on, intentamos pedir permiso si falta
    await _ensurePerm();
    // La revalidación también ocurrirá al volver, pero actualizamos por si quedó en foreground
    await _refreshGpsStates();
    _syncStatusText();
  }

  void _startAccelerometers() {
    if (!_accelerometerAvailable) {
      _showSnack('Acelerómetro no disponible en este dispositivo.');
      return;
    }
    _accSub = _accStreamUC().listen((a) => setState(() => _lastAcc = a));
    _userAccSub = _userAccStreamUC().listen(
      (ua) => setState(() => _lastUserAcc = ua),
    );
  }

  Future<void> _stopAccelerometers() async {
    await _accSub?.cancel();
    await _userAccSub?.cancel();
    _accSub = _userAccSub = null;
  }

  Future<void> _readLocation() async {
    if (!(_gpsServiceEnabled && _gpsPermissionOk)) {
      _showSnack('GPS no listo. Actívalo y otorga permiso.');
      return;
    }
    setState(() => _status = 'Obteniendo ubicación...');
    try {
      final loc = await _getCurrentLocation(
        timeout: const Duration(seconds: 8),
        accuracy: LocationAccuracyLevel.best,
      );
      setState(() {
        _loc = loc;
        _syncStatusText();
      });
    } catch (e) {
      setState(() => _status = 'Error: $e');
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _locServiceSub?.cancel();
    _stopAccelerometers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final acc = _lastAcc == null
        ? '-'
        : 'acc: ${_lastAcc!.x.toStringAsFixed(2)}, ${_lastAcc!.y.toStringAsFixed(2)}, ${_lastAcc!.z.toStringAsFixed(2)}';
    final uacc = _lastUserAcc == null
        ? '-'
        : 'userAcc: ${_lastUserAcc!.x.toStringAsFixed(2)}, ${_lastUserAcc!.y.toStringAsFixed(2)}, ${_lastUserAcc!.z.toStringAsFixed(2)}';
    final info = _loc == null ? 'Sin ubicación' : _loc.toString();

    final gpsReady = _gpsServiceEnabled && _gpsPermissionOk;
    final accelReady = _accelerometerAvailable;

    return Scaffold(
      appBar: AppBar(title: const Text('Location & Accelerometer Demo')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Estado: $_status'),
            const SizedBox(height: 8),
            Text(info),
            const SizedBox(height: 8),
            Text(acc),
            Text(uacc),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                // Activa GPS/permiso cuando haga falta; al volver, se revalida solo
                ElevatedButton.icon(
                  onPressed: _ensureGpsReady,
                  icon: const Icon(Icons.location_on_outlined),
                  label: const Text('Activar GPS / Permiso'),
                ),
                // Ubicación: solo activo si GPS listo
                ElevatedButton(
                  onPressed: gpsReady ? _readLocation : null,
                  child: const Text('Ubicación'),
                ),
                // Acelerómetro: solo activo si disponible
                ElevatedButton(
                  onPressed: accelReady
                      ? (_accSub == null
                            ? _startAccelerometers
                            : _stopAccelerometers)
                      : null,
                  child: Text(
                    _accSub == null
                        ? 'Iniciar acelerómetro'
                        : 'Detener acelerómetro',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
