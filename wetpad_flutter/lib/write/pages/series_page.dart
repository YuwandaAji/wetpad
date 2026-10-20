import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme.dart';

// Ganti dengan link yang sesuai untuk tombol "Learn more"
const _learnMoreUrl = 'https://creators.wattpad.com/writing-resources/';

class SeriesPage extends StatelessWidget {
  const SeriesPage({super.key});

  Future<void> _openLearnMore(BuildContext context) async {
    final ok = await launchUrl(
      Uri.parse(_learnMoreUrl),
      mode: LaunchMode.externalApplication,
    );
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Tidak bisa membuka link')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Series',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        titleSpacing: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const _SeriesIllustration(),
              const SizedBox(height: 24),
              const Text(
                'No series created',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Log in to Wetpad on desktop web to create and edit your '
                'series. Any changes you make will appear in the app.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey, height: 1.5),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () => _openLearnMore(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: const StadiumBorder(),
                  ),
                  child: const Text(
                    'Learn more',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Ilustrasi: satu kotak besar dan dua kotak kecil bertumpuk di sampingnya.
class _SeriesIllustration extends StatelessWidget {
  const _SeriesIllustration();

  static const _boxColor = Color(0xFFE0E0E0);

  Widget _box(double w, double h) {
    return Container(
      width: w,
      height: h,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _boxColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'w',
        style: TextStyle(
          color: Colors.white,
          fontSize: h > 100 ? 36 : 18,
          fontWeight: FontWeight.w900,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _box(112, 172),
        const SizedBox(width: 6),
        Column(
          children: [_box(54, 82), const SizedBox(height: 6), _box(54, 82)],
        ),
      ],
    );
  }
}
