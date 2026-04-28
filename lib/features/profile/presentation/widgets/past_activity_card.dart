import 'package:flutter/material.dart';
import 'package:runconnect/core/theme/app_colors.dart';
import 'package:runconnect/core/theme/app_text_styles.dart';
import 'package:runconnect/features/profile/domain/entities/past_activity.dart';

class PastActivityCard extends StatelessWidget {
  const PastActivityCard({super.key, required this.activity});

  final PastActivity activity;

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  String _formatDate(DateTime d) => '${_months[d.month - 1]} ${d.day}';

  String _formatDistance(double km) => km.truncateToDouble() == km
      ? '${km.toInt()}km'
      : '${km.toStringAsFixed(1)}km';

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: _Banner(imageUrl: activity.bannerImageUrl),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        activity.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onBackground,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatDate(activity.date),
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.onBackground,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Distance', style: AppTextStyles.caption),
                    Text('Pace', style: AppTextStyles.caption),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _MetricValue(value: _formatDistance(activity.distanceKm)),
                    _MetricValue(value: '${activity.formattedPace}/km'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricValue extends StatelessWidget {
  const _MetricValue({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    return Text(
      value,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: AppColors.primary,
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null) {
      return Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const _BannerFallback(),
      );
    }
    return const _BannerFallback();
  }
}

class _BannerFallback extends StatelessWidget {
  const _BannerFallback();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: const [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFD8EBDC), Color(0xFF8FB89A)],
            ),
          ),
        ),
        Center(
          child: Icon(
            Icons.directions_run,
            size: 56,
            color: Color(0xCC1B3D2F),
          ),
        ),
      ],
    );
  }
}
