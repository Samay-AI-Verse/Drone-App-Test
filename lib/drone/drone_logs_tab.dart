import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DroneLogsTab extends StatelessWidget {
  final String droneId;
  const DroneLogsTab({super.key, required this.droneId});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mission Logs',
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -1,
                    ),
                  ),
                  Text(
                    'Real-time telemetry events',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding:
                    const EdgeInsets.only(left: 24, right: 24, bottom: 100),
                itemCount: 8,
                separatorBuilder: (c, i) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  return _LogItem(
                    index: index,
                    message: index == 0
                        ? 'Connected to Trinetra Server'
                        : 'Telemetry packet sent successfully',
                    time: '12:${30 + index}:00',
                    isError: false,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LogItem extends StatelessWidget {
  final int index;
  final String message;
  final String time;
  final bool isError;

  const _LogItem({
    required this.index,
    required this.message,
    required this.time,
    required this.isError,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: const Center(
              child: Icon(Icons.code, size: 16, color: Colors.black),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                Text(
                  time,
                  style: GoogleFonts.inter(
                    color: Colors.grey,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
