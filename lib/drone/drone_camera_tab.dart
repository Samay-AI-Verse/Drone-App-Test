import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DroneCameraTab extends StatefulWidget {
  final String droneId;
  const DroneCameraTab({super.key, required this.droneId});

  @override
  State<DroneCameraTab> createState() => _DroneCameraTabState();
}

class _DroneCameraTabState extends State<DroneCameraTab>
    with WidgetsBindingObserver {
  CameraController? _controller;
  bool _isCameraInitialized = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() => _errorMessage = 'No cameras found');
        return;
      }

      final firstCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      _controller = CameraController(
        firstCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _controller!.initialize();

      if (mounted) {
        setState(() => _isCameraInitialized = true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = 'Camera Error: $e');
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null || !_controller!.value.isInitialized) return;

    if (state == AppLifecycleState.inactive) {
      _controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              style: GoogleFonts.inter(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (!_isCameraInitialized || _controller == null) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.black),
      );
    }

    // Use LayoutBuilder to ensure we cover everything or rely on Stack fit
    // Since we use extendBody: true in Scaffold, this widget takes full height.
    return Stack(
      fit: StackFit.expand,
      children: [
        // Camera Preview
        CameraPreview(_controller!),

        // Gradient Overlay for better text visibility
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.3),
                Colors.transparent,
                Colors.black.withValues(alpha: 0.3),
              ],
            ),
          ),
        ),

        // UI Overlays
        SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Tags
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _MinimalChip(
                      label: 'LIVE FEED',
                      bgColor: Colors.redAccent,
                      textColor: Colors.white,
                      isPulsing: true,
                    ),
                    _MinimalChip(
                      label: widget.droneId,
                      bgColor: Colors.black.withValues(alpha: 0.5),
                      textColor: Colors.white,
                      icon: Icons.flight,
                    ),
                  ],
                ),

                const Spacer(),

                // Center Reticle (HUD style)
                Center(
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Stack(
                      children: [
                        // Corner markers could go here
                        Center(
                          child: Icon(
                            Icons.add,
                            color: Colors.white.withValues(alpha: 0.5),
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(),
                const SizedBox(height: 80), // Space for Bottom Nav
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MinimalChip extends StatefulWidget {
  final String label;
  final Color bgColor;
  final Color textColor;
  final bool isPulsing;
  final IconData? icon;

  const _MinimalChip({
    required this.label,
    required this.bgColor,
    required this.textColor,
    this.isPulsing = false,
    this.icon,
  });

  @override
  State<_MinimalChip> createState() => _MinimalChipState();
}

class _MinimalChipState extends State<_MinimalChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.3,
    ).animate(_animationController);

    if (widget.isPulsing) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: widget.bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.isPulsing)
            FadeTransition(
              opacity: _opacityAnimation,
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: widget.textColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          if (widget.icon != null)
            Padding(
              padding: const EdgeInsets.only(right: 6.0),
              child: Icon(widget.icon, color: widget.textColor, size: 14),
            ),
          Text(
            widget.label,
            style: GoogleFonts.inter(
              color: widget.textColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
