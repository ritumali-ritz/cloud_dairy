import 'package:flutter/material.dart';
import 'dart:async';

class WatermarkOverlay extends StatefulWidget {
  final Widget child;
  const WatermarkOverlay({super.key, required this.child});

  @override
  State<WatermarkOverlay> createState() => _WatermarkOverlayState();
}

class _WatermarkOverlayState extends State<WatermarkOverlay> {
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    // Hide after 20 seconds
    Timer(const Duration(seconds: 20), () {
      if (mounted) {
        setState(() {
          _isVisible = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_isVisible)
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: IgnorePointer( // Allow Clicks through
              child: Container(
                alignment: Alignment.center,
                child: Text(
                  'Developed by Ritex Studios',
                  style: TextStyle(
                    color: Colors.black.withAlpha(50), // Semi-transparent
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.none, // Since it might be outside Material
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
