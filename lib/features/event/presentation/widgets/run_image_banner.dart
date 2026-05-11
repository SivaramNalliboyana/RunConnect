import 'dart:io';

import 'package:flutter/material.dart';

class RunImageBanner extends StatelessWidget {
  const RunImageBanner({
    super.key,
    this.imagePath,
    this.imageUrl,
    this.onTap,
    this.showEditIcon = true,
  });

  final String? imagePath;
  final String? imageUrl;
  final VoidCallback? onTap;
  final bool showEditIcon;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: InkWell(
          onTap: onTap,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (imagePath != null)
                Image.file(File(imagePath!), fit: BoxFit.cover)
              else if (imageUrl != null && imageUrl!.isNotEmpty)
                Image.network(
                  imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _fallback(),
                )
              else
                _fallback(),
              if (showEditIcon)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt_outlined,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              const Positioned(
                left: 16,
                bottom: 16,
                child: Text(
                  'Define Your Run',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    shadows: [
                      Shadow(blurRadius: 8, color: Colors.black54),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fallback() {
    return Stack(
      fit: StackFit.expand,
      children: const [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF6FA0B5),
                Color(0xFF4F7C8A),
                Color(0xFF3A2A20),
              ],
              stops: [0.0, 0.7, 1.0],
            ),
          ),
        ),
        Center(
          child: Icon(
            Icons.directions_run,
            size: 96,
            color: Color(0xCC1A1A1A),
          ),
        ),
      ],
    );
  }
}
