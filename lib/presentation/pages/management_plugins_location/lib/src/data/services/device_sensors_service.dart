import 'dart:async';

import 'package:geolocator/geolocator.dart' as geo;
import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:sensors_plus/sensors_plus.dart';

import '../../core/errors/failures.dart';
import '../../domain/entities/device_location.dart';
import '../../domain/repositories/device_sensors_repository.dart';

class DeviceSensorsService implements DeviceSensorsRepository {
  // cache de últimas lecturas
  ({double x, double y, double z})? _lastAcc;
  ({double x, double y, double z})? _lastUserAcc;

  @override
  Future<bool> isLocationServiceEnabled() async {
    return await geo.Geolocator.isLocationServiceEnabled();
  }

  @override
  Future<bool> ensureLocationPermission() async {
    final serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    var permission = await geo.Geolocator.checkPermission();
    if (permission == geo.LocationPermission.denied) {
      permission = await geo.Geolocator.requestPermission();
    }
    if (permission == geo.LocationPermission.deniedForever) return false;

    return permission == geo.LocationPermission.whileInUse ||
        permission == geo.LocationPermission.always;
  }

  @override
  Future<void> openLocationSettings() async {
    await geo.Geolocator.openLocationSettings();
  }

  @override
  Future<void> openAppSettings() async {
    await ph.openAppSettings();
  }

  geo.LocationAccuracy _mapAccuracy(LocationAccuracyLevel accuracy) {
    switch (accuracy) {
      case LocationAccuracyLevel.low:
        return geo.LocationAccuracy.low;
      case LocationAccuracyLevel.balanced:
        return geo.LocationAccuracy.medium;
      case LocationAccuracyLevel.high:
        return geo.LocationAccuracy.high;
      case LocationAccuracyLevel.best:
        return geo.LocationAccuracy.best;
    }
  }

  @override
  Future<DeviceLocation> getCurrentLocation({
    Duration timeout = const Duration(seconds: 10),
    LocationAccuracyLevel accuracy = LocationAccuracyLevel.best,
  }) async {
    final hasPerm = await ensureLocationPermission();
    if (!hasPerm) {
      throw const PermissionFailure(
        'Ubicación sin permiso o servicio deshabilitado.',
      );
    }

    try {
      final pos = await geo.Geolocator.getCurrentPosition(
        desiredAccuracy: _mapAccuracy(accuracy),
        timeLimit: timeout,
      );

      return DeviceLocation(
        latitude: pos.latitude,
        longitude: pos.longitude,
        altitude: pos.altitude ?? 0.0,
        timestamp: pos.timestamp ?? DateTime.now(),
      );
    } on TimeoutException catch (e, st) {
      throw TimeoutFailure(
        'Timeout obteniendo ubicación',
        cause: e,
        stackTrace: st,
      );
    } catch (e, st) {
      throw UnknownFailure(
        'Error obteniendo ubicación',
        cause: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<bool> isAccelerometerAvailable({
    Duration timeout = const Duration(milliseconds: 800),
  }) async {
    final completer = Completer<bool>();
    late final StreamSubscription sub;
    bool seen = false;

    sub = accelerometerEvents.listen(
      (_) {
        seen = true;
        if (!completer.isCompleted) completer.complete(true);
        sub.cancel();
      },
      onError: (_) {
        if (!completer.isCompleted) completer.complete(false);
        sub.cancel();
      },
    );

    Future.delayed(timeout, () {
      if (!completer.isCompleted) {
        completer.complete(seen);
        sub.cancel();
      }
    });

    return completer.future;
  }

  @override
  Stream<({double x, double y, double z})> accelerometerStream() {
    return accelerometerEvents.map((e) {
      final s = (x: e.x, y: e.y, z: e.z);
      _lastAcc = s;
      return s;
    });
  }

  @override
  Stream<({double x, double y, double z})> userAccelerometerStream() {
    return userAccelerometerEvents.map((e) {
      final s = (x: e.x, y: e.y, z: e.z);
      _lastUserAcc = s;
      return s;
    });
  }

  @override
  ({double x, double y, double z})? get lastAccelerometer => _lastAcc;

  @override
  ({double x, double y, double z})? get lastUserAccelerometer => _lastUserAcc;
}
