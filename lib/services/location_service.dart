import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  String? _droneId;
  String? _nickname;
  StreamSubscription<Position>? _positionStreamSubscription;
  bool _isTracking = false;

  // Production backend URL (Render deployment)
  // For local development, change to: 'http://10.0.2.2:8000' for Android Emulator
  // or 'http://192.168.x.x:8000' for physical device
  // Using ngrok for development testing
  static const String _baseUrl =
      'https://overprosperous-aviana-nontextually.ngrok-free.dev';

  bool get isTracking => _isTracking;

  Future<bool> requestPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('Location services are disabled.');
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        debugPrint('Location permissions are denied');
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      debugPrint(
          'Location permissions are permanently denied, we cannot request permissions.');
      return false;
    }

    return true;
  }

  void startTracking({required String droneId, String? nickname}) async {
    if (_isTracking) return;
    _droneId = droneId;
    _nickname = nickname;
    _isTracking = true;

    // Send initial status
    await _sendStatusUpdate(isLive: true);

    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 0, // Update every change, but we rely mostly on time
    );

    // We want updates every 1-2 seconds.
    // Geolocator stream sends updates when location changes.
    // To force 1-2s intervals, we might need a Timer + getCurrentPosition
    // OR just rely on stream updates which usually happen frequently when moving or set time limit (Android specific).
    // For now, let's use the stream.

    _positionStreamSubscription =
        Geolocator.getPositionStream(locationSettings: locationSettings).listen(
            (Position position) {
      _sendLocationUpdate(position);
    }, onError: (e) {
      debugPrint('Location Stream Error: $e');
    });

    debugPrint('Started tracking for $_droneId');
  }

  void stopTracking() async {
    if (!_isTracking) return;
    _isTracking = false;
    await _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;

    await _sendStatusUpdate(isLive: false);
    debugPrint('Stopped tracking for $_droneId');
    _droneId = null;
    _nickname = null;
  }

  Future<void> _sendLocationUpdate(Position position) async {
    if (_droneId == null) return;

    final url = Uri.parse('$_baseUrl/api/drones/$_droneId/location');
    try {
      final body = jsonEncode({
        "lat": position.latitude,
        "lng": position.longitude,
        "speed": position.speed, // m/s
        "heading": position.heading,
        "alt": position.altitude,
        "nickname": _nickname,
        "is_live": true,
        "timestamp": DateTime.now()
            .toIso8601String(), // Optional, backend handles it too
      });

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode != 200) {
        debugPrint('Failed to send location: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error sending location: $e');
    }
  }

  Future<void> _sendStatusUpdate({required bool isLive}) async {
    if (_droneId == null) return;

    final url = Uri.parse('$_baseUrl/api/drones/$_droneId/status');
    try {
      await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "is_live": isLive,
          "nickname": _nickname,
        }),
      );
    } catch (e) {
      debugPrint('Error sending status: $e');
    }
  }
}
