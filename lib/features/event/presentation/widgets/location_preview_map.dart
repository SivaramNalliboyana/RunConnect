import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:runconnect/core/theme/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class LocationPreviewMap extends StatelessWidget {
  const LocationPreviewMap({
    super.key,
    required this.lat,
    required this.lng,
    required this.address,
    this.height = 220,
  });

  final double lat;
  final double lng;
  final String address;
  final double height;

  static const _pinHex = '1b3d2f'; // AppColors.primary without #
  static const _zoom = 14;

  Future<void> _openDirections() async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  String _buildStaticUrl(double width, double devicePixelRatio) {
    final token = dotenv.env['MAPBOX_PUBLIC_TOKEN'] ?? '';
    final scale = devicePixelRatio >= 1.5 ? '@2x' : '';
    final w = width.round().clamp(64, 1280);
    final h = height.round().clamp(64, 1280);
    return 'https://api.mapbox.com/styles/v1/mapbox/streets-v11/static/'
        'pin-l+$_pinHex($lng,$lat)/'
        '$lng,$lat,$_zoom/'
        '${w}x$h$scale'
        '?access_token=$token';
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final dpr = MediaQuery.devicePixelRatioOf(context);
        final url = _buildStaticUrl(constraints.maxWidth, dpr);

        return ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Material(
            color: AppColors.surfaceVariant,
            child: InkWell(
              onTap: _openDirections,
              child: SizedBox(
                height: height,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      url,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const _MapFallback(),
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return const _MapFallback();
                      },
                    ),
                    Align(
                      alignment: const Alignment(0, -0.4),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _AddressCallout(text: address),
                      ),
                    ),
                    const Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: _OpenInMapsHint(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AddressCallout extends StatelessWidget {
  const _AddressCallout({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 280),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.onBackground,
                height: 1.25,
              ),
            ),
          ),
          CustomPaint(
            size: const Size(14, 7),
            painter: _CalloutTail(color: AppColors.surface),
          ),
        ],
      ),
    );
  }
}

class _CalloutTail extends CustomPainter {
  _CalloutTail({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CalloutTail oldDelegate) =>
      oldDelegate.color != color;
}

class _OpenInMapsHint extends StatelessWidget {
  const _OpenInMapsHint();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.95),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Icon(
        Icons.open_in_new,
        size: 14,
        color: AppColors.primary,
      ),
    );
  }
}

class _MapFallback extends StatelessWidget {
  const _MapFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceVariant,
      child: const Center(
        child: Icon(
          Icons.location_on,
          size: 48,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
