import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DroneStatusTab extends StatelessWidget {
  final String droneId;
  const DroneStatusTab({super.key, required this.droneId});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F5F7), // "Dark White" / Light Grey background
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'System Check',
                style: GoogleFonts.inter(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -1),
              ),
              Text(
                'Telemetry for $droneId',
                style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.1,
                  padding: const EdgeInsets.only(bottom: 120), // Space for nav
                  children: const [
                    _StatusCard(
                        icon: Icons.speed,
                        label: 'Speed',
                        value: '0.0 m/s',
                        color: Colors.black),
                    _StatusCard(
                        icon: Icons.navigation,
                        label: 'Heading',
                        value: '350° N',
                        color: Colors.black),
                    _StatusCard(
                        icon: Icons.height,
                        label: 'Altitude',
                        value: '45 m',
                        color: Colors.black),
                    _StatusCard(
                        icon: Icons.battery_full,
                        label: 'Battery',
                        value: '88%',
                        color: Colors.green),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatusCard(
      {required this.icon,
      required this.label,
      required this.value,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 28),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: GoogleFonts.inter(
                      fontSize: 24, fontWeight: FontWeight.bold)),
              Text(label,
                  style: GoogleFonts.inter(fontSize: 13, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }
}
