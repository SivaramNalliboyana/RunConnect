class PastActivity {
  final String id;
  final String title;
  final DateTime date;
  final double distanceKm;
  final int paceSecondsPerKm;
  final String? bannerImageUrl;

  const PastActivity({
    required this.id,
    required this.title,
    required this.date,
    required this.distanceKm,
    required this.paceSecondsPerKm,
    this.bannerImageUrl,
  });

  String get formattedPace {
    final m = paceSecondsPerKm ~/ 60;
    final s = (paceSecondsPerKm % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
