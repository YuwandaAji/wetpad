
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/theme.dart';
import '../widgets/auth_widgets.dart';
import 'register_page.dart';
import 'login_page.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(children: [
          const Spacer(flex: 3),
          const WetpadLogo(color: AppColors.orange, size: 52),
          const SizedBox(height: 56),
          const Text('Komunitas global terbesar untuk bercerita',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, height: 1.25)),
          const SizedBox(height: 32),
          PillButton(
            'Daftar dengan Google',
            outlined: true,
            icon: ShaderMask(
              shaderCallback: (r) => const SweepGradient(colors: [
                Color(0xFF4285F4),
                Color(0xFF34A853),
                Color(0xFFFBBC05),
                Color(0xFFEA4335),
                Color(0xFF4285F4),
              ]).createShader(r),
              child: const FaIcon(FontAwesomeIcons.google, color: Colors.white, size: 24),
            ),
            onPressed: () => authSnack(context, 'Daftar dengan Google segera hadir.'),
          ),
          const SizedBox(height: 14),
          PillButton(
            'Daftar dengan Facebook',
            outlined: true,
            icon: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                  color: const Color(0xFF3B5998), borderRadius: BorderRadius.circular(4)),
              child: const Center(
                  child: FaIcon(FontAwesomeIcons.facebookF, color: Colors.white, size: 15)),
            ),
            onPressed: () => authSnack(context, 'Daftar dengan Facebook segera hadir.'),
          ),
          const SizedBox(height: 22),
          Row(children: const [
            Expanded(child: Divider(color: Colors.white24)),
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 14),
                child: Text('atau', style: TextStyle(color: AppColors.muted, fontSize: 16))),
            Expanded(child: Divider(color: Colors.white24)),
          ]),
          const SizedBox(height: 22),
          PillButton(
            'Daftar dengan email',
            onPressed: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const RegisterPage())),
          ),
          const Spacer(flex: 3),
          TextButton(
            onPressed: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const LoginPage())),
            child: const Text('Saya sudah memiliki akun',
                style: TextStyle(
                    color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 24),
        ]),
      ),
    );
  }
}