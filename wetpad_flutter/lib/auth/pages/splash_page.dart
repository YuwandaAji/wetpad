
import 'package:flutter/material.dart';
import '../../../core/config_api.dart';
import '../../../core/theme.dart';
import '../auth_nav.dart';
import '../services/auth_api.dart';
import '../widgets/auth_widgets.dart';
import 'welcome_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  // redup -> jelas -> redup -> jelas
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1800));

  late final Animation<double> _opacity = TweenSequence<double>([
    TweenSequenceItem(
        tween: Tween(begin: 0.15, end: 1.0).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 1),
    TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.15).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 1),
    TweenSequenceItem(
        tween: Tween(begin: 0.15, end: 1.0).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 1),
  ]).animate(_c);

  @override
  void initState() {
    super.initState();
    _boot();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Future<void> _boot() async {
    final anim = _c.forward(); // animasi jalan sambil token dicek

    var ok = false;
    if (Session.token != null) {
      ok = await AuthApi.isTokenValid();
      if (!ok) await Session.clear();
    }

    await anim; // tunggu animasi selesai
    await Future.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;

    if (ok) {
      goHome(context);
    } else {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const WelcomePage()));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.bg,
        body: Center(
          child: FadeTransition(
            opacity: _opacity,
            child: const WetpadLogo(color: AppColors.orange, size: 40),
          ),
        ),
      );
}