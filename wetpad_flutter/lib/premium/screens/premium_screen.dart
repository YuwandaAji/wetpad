import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

const _navy = Color(0xFF2E2663);
const _idleBar = Color(0xFF6B6E85);
const _idleText = Color(0xFF5B5885);

// Ganti dengan alamat asli saat halamannya sudah ada.
const _learnUrl = 'https://wetpad.app/premium';
const _privacyUrl = 'https://wetpad.app/privacy';
const _termsUrl = 'https://wetpad.app/terms';

class _Plan {
  final String id; // samakan dengan product ID di Google Play
  final String title;
  final String billing;
  final String price;
  final String period;
  final String? perMonth;
  const _Plan({
    required this.id,
    required this.title,
    required this.billing,
    required this.price,
    required this.period,
    this.perMonth,
  });
}

class _Tier {
  final String tabLabel;
  final String logoSuffix;
  final String headline;
  final IconData icon;
  final List<Color> iconColors;
  final List<String> benefits;
  final List<_Plan> plans;
  final int defaultPlan;
  final bool freeTrial;
  const _Tier({
    required this.tabLabel,
    required this.logoSuffix,
    required this.headline,
    required this.icon,
    required this.iconColors,
    required this.benefits,
    required this.plans,
    required this.defaultPlan,
    required this.freeTrial,
  });
}

const _tiers = <_Tier>[
  _Tier(
    tabLabel: 'Wetpad\nPremium',
    logoSuffix: 'premium',
    headline: 'Katakan selamat tinggal ke iklan dan sambutlah cerita offline tanpa batas',
    icon: Icons.favorite,
    iconColors: [Color(0xFFFFFFFF), Color(0xFF9DB0E4), Color(0xFFFFFFFF)],
    benefits: [
      'Tanpa iklan',
      'Cerita offline tanpa batas',
      'Termasuk Wetpad Originals pilihan tiap bulan',
    ],
    plans: [
      _Plan(
        id: 'premium_monthly',
        title: 'Bulanan',
        billing: 'Otomatis diperbarui dan ditagih bulanan',
        price: 'Rp45.000',
        period: 'bulan',
      ),
      _Plan(
        id: 'premium_yearly',
        title: 'Tahunan',
        billing: 'Otomatis diperbarui dan ditagih tahunan',
        price: 'Rp450.000',
        period: 'tahun',
        perMonth: '(Rp37.500/bulan)',
      ),
      _Plan(
        id: 'premium_semiannual',
        title: 'Semi-Tahunan',
        billing: 'Otomatis diperbarui dan ditagih semi-tahunan',
        price: 'Rp260.000',
        period: '6 bulan',
        perMonth: '(Rp43.333,33/bulan)',
      ),
    ],
    defaultPlan: 0,
    freeTrial: true,
  ),
  _Tier(
    tabLabel: 'Wetpad\nPremium+',
    logoSuffix: 'premium +',
    headline: 'Buka akses cerita terpopuler dengan 200 Bonus Koin',
    icon: Icons.auto_awesome,
    iconColors: [Color(0xFFFFB300), Color(0xFFFFFFFF), Color(0xFF9DB0E4)],
    benefits: [
      '200 Bonus Koin per bulan (Bonus Koin kedaluwarsa dalam 30 hari setelah diterima)',
      'Termasuk Wetpad Originals pilihan tiap bulan',
      'Tanpa iklan',
      'Cerita offline tanpa batas',
    ],
    plans: [
      _Plan(
        id: 'premium_plus_monthly',
        title: 'Bulanan',
        billing: 'Otomatis diperbarui dan ditagih bulanan',
        price: 'Rp129.000',
        period: 'bulan',
      ),
      _Plan(
        id: 'premium_plus_yearly',
        title: 'Tahunan',
        billing: 'Otomatis diperbarui dan ditagih tahunan',
        price: 'Rp1.309.898',
        period: 'tahun',
        perMonth: '(Rp109.158/bulan)',
      ),
    ],
    defaultPlan: 1,
    freeTrial: false,
  ),
];

class PremiumScreen extends StatefulWidget {
  final bool startOnPlus;

  /// Dipanggil saat tombol langganan ditekan. Sambungkan ke in_app_purchase
  /// atau backend kamu. Jika null, hanya muncul snackbar.
  final Future<void> Function(String planId)? onSubscribe;

  /// Dipanggil saat "Pulihkan Pembelian" ditekan.
  final Future<void> Function()? onRestore;

  const PremiumScreen({
    super.key,
    this.startOnPlus = false,
    this.onSubscribe,
    this.onRestore,
  });

  static Future<void> open(BuildContext context, {bool plus = false}) =>
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          fullscreenDialog: true,
          builder: (_) => PremiumScreen(startOnPlus: plus),
        ),
      );

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  late int _tier = widget.startOnPlus ? 1 : 0;
  late final List<int> _selected = [for (final t in _tiers) t.defaultPlan];
  bool _busy = false;

  _Tier get _t => _tiers[_tier];
  _Plan get _plan => _t.plans[_selected[_tier]];

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _subscribe() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final cb = widget.onSubscribe;
      if (cb == null) {
        _snack(
          'Paket dipilih: ${_t.tabLabel.replaceAll('\n', ' ')} - ${_plan.title}',
        );
      } else {
        await cb(_plan.id);
      }
    } catch (e) {
      _snack('$e'.replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _restore() async {
    try {
      final cb = widget.onRestore;
      if (cb == null) {
        _snack('Memeriksa pembelian sebelumnya…');
      } else {
        await cb();
      }
    } catch (e) {
      _snack('$e'.replaceFirst('Exception: ', ''));
    }
  }

  Future<void> _open(String url) async {
    try {
      final ok = await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
      if (!ok) _snack('Tidak dapat membuka tautan');
    } catch (_) {
      _snack('Tidak dapat membuka tautan');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFB9C6F6), Color(0xFF9FA8F2), Color(0xFF7C80F0)],
            stops: [0, 0.55, 1],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _header(),
              Expanded(child: _content()),
              _footer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: InkResponse(
              onTap: () => Navigator.of(context).maybePop(),
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.black, size: 24),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              for (var i = 0; i < _tiers.length; i++) ...[
                if (i > 0) const SizedBox(width: 12),
                Expanded(child: _tab(i)),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _tab(int i) {
    final active = i == _tier;
    return Semantics(
      button: true,
      selected: active,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => setState(() => _tier = i),
        child: Column(
          children: [
            Text(
              _tiers[i].tabLabel,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                height: 1.2,
                fontWeight: FontWeight.w600,
                color: active ? _navy : _idleText,
              ),
            ),
            const SizedBox(height: 8),
            Container(height: 5, color: active ? _navy : _idleBar),
          ],
        ),
      ),
    );
  }

  Widget _content() {
    final t = _t;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              const Text(
                'W',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                  color: _navy,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                t.logoSuffix,
                style: const TextStyle(fontSize: 28, color: _navy),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            t.headline,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              height: 1.2,
              fontWeight: FontWeight.w700,
              color: _navy,
            ),
          ),
          const SizedBox(height: 14),
          ShaderMask(
            shaderCallback: (r) =>
                LinearGradient(colors: t.iconColors).createShader(r),
            child: Icon(t.icon, size: 64, color: Colors.white),
          ),
          const SizedBox(height: 14),
          for (final b in t.benefits)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check, color: _navy, size: 26),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      b,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.25,
                        fontWeight: FontWeight.w500,
                        color: _navy,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          for (var i = 0; i < t.plans.length; i++) _planCard(t.plans[i], i),
        ],
      ),
    );
  }

  Widget _planCard(_Plan p, int index) {
    final selected = _selected[_tier] == index;
    final fg = selected ? Colors.white : _navy;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Semantics(
        button: true,
        selected: selected,
        label: '${p.title}, ${p.price}',
        child: GestureDetector(
          onTap: () => setState(() => _selected[_tier] = index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.fromLTRB(20, 18, 16, 18),
            decoration: BoxDecoration(
              color: selected ? _navy : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected ? Colors.white : Colors.transparent,
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: fg,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        p.billing,
                        style: TextStyle(fontSize: 14, height: 1.25, color: fg),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      p.price,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: fg,
                      ),
                    ),
                    if (p.perMonth != null)
                      Text(
                        p.perMonth!,
                        style: TextStyle(fontSize: 14, color: fg),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Icon(
                  selected ? Icons.check_circle : Icons.radio_button_unchecked,
                  size: 34,
                  color: selected ? const Color(0xFFB9C6F6) : _navy,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _footer() {
    const legal = TextStyle(
      fontSize: 13.5,
      height: 1.3,
      color: Colors.white,
      fontWeight: FontWeight.w500,
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Dengan mengklik "Langganan sekarang", kamu setuju bahwa paket yang kamu pilih akan otomatis diperbarui dengan harga yang tertera di atas kecuali dibatalkan paling lambat satu hari sebelum tanggal pembaruan. Batalkan kapan saja pada menu Langganan di Google Play untuk Android. Jika dibatalkan, kamu tetap memiliki akses hingga tanggal pembaruan.',
            textAlign: TextAlign.center,
            style: legal,
          ),
          if (_t.freeTrial) ...[
            const SizedBox(height: 10),
            const Text(
              'Uji coba gratis khusus pelanggan baru. Otomatis diperbarui ke langganan berbayar kecuali dibatalkan dalam 7 hari.',
              textAlign: TextAlign.center,
              style: legal,
            ),
          ],
          const SizedBox(height: 14),
          Text(
            '${_plan.price} / ${_plan.period} sampai dibatalkan. Batalkan kapan saja.',
            textAlign: TextAlign.center,
            style: legal,
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 62,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: _navy,
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onPressed: _busy ? null : _subscribe,
              child: _busy
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      _t.freeTrial
                          ? 'Langganan sekarang dengan uji coba gratis 7 hari'
                          : 'Langganan sekarang',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              _link('Pulihkan\nPembelian', _restore),
              _link('Pelajari lebih\nlanjut', () => _open(_learnUrl)),
              _link('Kebijakan\nPrivasi', () => _open(_privacyUrl)),
              _link('Persyaratan\nLayanan', () => _open(_termsUrl)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _link(String label, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              height: 1.2,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
