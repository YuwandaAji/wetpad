String compactNumber(int n) {
  if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
  if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
  return '$n';
}

/// 35700 -> "35.7k" (lowercase k, like Wattpad's follower count).
String followersLabel(int n) {
  if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
  if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
  return '$n';
}

String timeAgoLabel(int minutes) {
  if (minutes < 60) return '$minutes mnt lalu';
  if (minutes < 60 * 24) return '${minutes ~/ 60} j lalu';
  return '${minutes ~/ (60 * 24)} hr lalu';
}
/// 185000 -> "185 Rb", 15800 -> "15,8 Rb", 83800000 -> "83,8 Jt"
String idCompact(int n) {
  String f(double v) {
    final s = v.toStringAsFixed(1);
    return (s.endsWith('.0') ? s.substring(0, s.length - 2) : s)
        .replaceAll('.', ',');
  }

  if (n >= 1000000) return '${f(n / 1000000)} Jt';
  if (n >= 1000) return '${f(n / 1000)} Rb';
  return '$n';
}
