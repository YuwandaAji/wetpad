
const _bulan = ['Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agu','Sep','Okt','Nov','Des'];

String fmtDate(DateTime d) => '${_bulan[d.month - 1]} ${d.day}, ${d.year}'; // Jul 4, 2026

String fmtCount(int n) {
  String f(double v, String unit) {
    final s = v
        .toStringAsFixed(2)
        .replaceFirst(RegExp(r'\.?0+$'), '')
        .replaceAll('.', ',');
    return '$s $unit';
  }

  if (n >= 1000000) return f(n / 1000000, 'Jt');
  if (n >= 1000) return f(n / 1000, 'Rb'); // 7,93 Rb
  return '$n';
}

String timeAgo(DateTime d) {
  final s = DateTime.now().difference(d);
  if (s.inMinutes < 1) return 'Baru saja';
  if (s.inMinutes < 60) return '${s.inMinutes} mnt lalu';
  if (s.inHours < 24) return '${s.inHours} j lalu';
  if (s.inDays < 7) return '${s.inDays} hr lalu';
  if (s.inDays < 30) return '${s.inDays ~/ 7} mgg lalu';
  if (s.inDays < 365) return '${s.inDays ~/ 30} bl lalu';
  return '${s.inDays ~/ 365} th lalu';
}