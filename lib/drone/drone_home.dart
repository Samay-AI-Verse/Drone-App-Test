import 'package:flutter/material.dart';
import 'drone_camera_tab.dart';
import 'drone_status_tab.dart';
import 'drone_logs_tab.dart';
import '../widgets/creative_bottom_nav.dart';
import '../services/location_service.dart';
import '../main.dart'; // Import main to access DroneApp for restart

class DroneHome extends StatefulWidget {
  final String droneId;

  const DroneHome({super.key, this.droneId = 'Unit-1'});

  @override
  State<DroneHome> createState() => _DroneHomeState();
}

class _DroneHomeState extends State<DroneHome> {
  int _currentIndex = 0;
  late final List<Widget> _tabs;

  @override
  void initState() {
    super.initState();
    // Initialize tabs once to keep state alive
    _tabs = [
      DroneCameraTab(droneId: widget.droneId),
      DroneStatusTab(droneId: widget.droneId),
      DroneLogsTab(droneId: widget.droneId),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        _handleExit(); // Prevent accidental back button
      },
      child: Scaffold(
        backgroundColor: Colors.black, // Dark background behind everything
        extendBody: true, // CRITICAL: Allows camera to go behind the nav bar
        body: IndexedStack(
          index: _currentIndex,
          children: _tabs,
        ),
        bottomNavigationBar: CreativeBottomNav(
          currentIndex: _currentIndex,
          onTap: (i) {
            if (i == 3) {
              // Index 3 is our "OFF" / Logout button
              _handleExit();
            } else {
              setState(() => _currentIndex = i);
            }
          },
          items: [
            CreativeNavItem(icon: Icons.videocam_outlined, label: 'LIVE'),
            CreativeNavItem(icon: Icons.speed, label: 'STATUS'),
            CreativeNavItem(icon: Icons.article_outlined, label: 'LOGS'),
            CreativeNavItem(icon: Icons.power_settings_new, label: 'OFF'),
          ],
        ),
      ),
    );
  }

  void _handleExit() {
    // 1. Stop tracking location
    LocationService().stopTracking();

    // 2. Navigate back to Login Screen cleanly
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const DroneApp()),
      (Route<dynamic> route) => false,
    );
  }
}
