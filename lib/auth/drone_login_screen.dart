import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../drone/drone_home.dart';
import '../services/location_service.dart';

class DroneLoginScreen extends StatefulWidget {
  const DroneLoginScreen({super.key});

  @override
  State<DroneLoginScreen> createState() => _DroneLoginScreenState();
}

class _DroneLoginScreenState extends State<DroneLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _nicknameController = TextEditingController();
  bool _isLoading = false;

  void _activate() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final hasPermission = await LocationService().requestPermission();
    if (!hasPermission) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Permission denied')));
      setState(() => _isLoading = false);
      return;
    }

    LocationService().startTracking(
      droneId: _idController.text,
      nickname:
          _nicknameController.text.isEmpty ? null : _nicknameController.text,
    );

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => DroneHome(droneId: _idController.text)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Spacer(flex: 2),
                          const Icon(Icons.flight_takeoff, size: 48),
                          const SizedBox(height: 24),
                          Text('Deploy Unit',
                              style: GoogleFonts.inter(
                                  fontSize: 32, fontWeight: FontWeight.bold)),
                          Text('Initialize autonomous connection.',
                              style:
                                  GoogleFonts.inter(color: Colors.grey[600])),
                          const SizedBox(height: 48),
                          _MinimalInput(
                              controller: _idController,
                              label: 'Drone ID',
                              icon: Icons.qr_code),
                          const SizedBox(height: 16),
                          _MinimalInput(
                              controller: _nicknameController,
                              label: 'Nickname',
                              icon: Icons.text_fields),
                          const Spacer(flex: 3),
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _activate,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                              ),
                              child: _isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white)
                                  : Text('INITIALIZE SYSTEM',
                                      style: GoogleFonts.inter(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white)),
                            ),
                          ),
                          const Spacer(flex: 1),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _MinimalInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;

  const _MinimalInput(
      {required this.controller, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F7),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          border: InputBorder.none,
          labelText: label,
          icon: Icon(icon, color: Colors.black54),
        ),
        validator: (value) => value!.isEmpty ? 'Required' : null,
      ),
    );
  }
}
