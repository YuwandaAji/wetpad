
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/theme.dart';
import '../auth_nav.dart';
import '../services/auth_api.dart';
import '../widgets/auth_widgets.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _id = TextEditingController();
  final _pw = TextEditingController();
  bool _hide = true, _submitted = false, _loading = false;
  final Set<String> _touched = {};
  String? _failMsg; // pesan "login gagal" dari server

  @override
  void dispose() {
    _id.dispose();
    _pw.dispose();
    super.dispose();
  }

  bool _show(String k) => _submitted || _touched.contains(k);

  String? get _idError => (_show('id') && _id.text.trim().isEmpty)
      ? 'Email atau nama pengguna wajib diisi.'
      : null;

  String? get _pwError =>
      _failMsg ?? ((_show('pw') && _pw.text.isEmpty) ? 'Kata sandi wajib diisi.' : null);

  // login gagal: kedua kolom merah, pesan hanya di bawah kata sandi
  FieldStatus get _idStatus =>
      (_idError != null || _failMsg != null) ? FieldStatus.error : FieldStatus.neutral;
  FieldStatus get _pwStatus => _pwError != null ? FieldStatus.error : FieldStatus.neutral;

  Future<void> _submit() async {
    if (_loading) return;
    setState(() {
      _submitted = true;
      _failMsg = null;
    });
    if (_id.text.trim().isEmpty || _pw.text.isEmpty) return;

    FocusScope.of(context).unfocus();
    setState(() => _loading = true);
    try {
      await AuthApi.login(login: _id.text.trim(), password: _pw.text);
      if (!mounted) return;
      goHome(context);
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _failMsg = e.fields.isNotEmpty ? e.fields.values.first : e.message;
          _pw.clear(); // seperti Wattpad: kata sandi dikosongkan setelah gagal
        });
      }
    } catch (_) {
      if (mounted) authSnack(context, 'Tidak bisa terhubung ke server.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      child: Column(children: [
        Expanded(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(28, 32, 28, 16),
            child: Column(children: [
              const WetpadLogo(color: AppColors.orange, size: 30),
              const SizedBox(height: 28),
              PillButton(
                'Masuk dengan Google',
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
                onPressed: () => authSnack(context, 'Masuk dengan Google segera hadir.'),
              ),
              const SizedBox(height: 20),
              PillButton(
                'Masuk dengan Facebook',
                outlined: true,
                icon: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                      color: const Color(0xFF3B5998),
                      borderRadius: BorderRadius.circular(4)),
                  child: const Center(
                      child: FaIcon(FontAwesomeIcons.facebookF,
                          color: Colors.white, size: 15)),
                ),
                onPressed: () => authSnack(context, 'Masuk dengan Facebook segera hadir.'),
              ),
              const SizedBox(height: 26),
              Row(children: const [
                Expanded(child: Divider(color: Colors.white12)),
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14),
                    child: Text('atau',
                        style: TextStyle(color: AppColors.muted, fontSize: 16))),
                Expanded(child: Divider(color: Colors.white12)),
              ]),
              const SizedBox(height: 28),
              AuthField(
                controller: _id,
                label: 'Email atau nama pengguna',
                keyboard: TextInputType.emailAddress,
                action: TextInputAction.next,
                status: _idStatus,
                error: _idError,
                onChanged: (_) => setState(() => _failMsg = null),
                onBlur: () => setState(() => _touched.add('id')),
              ),
              const SizedBox(height: 28),
              AuthField(
                controller: _pw,
                label: 'Kata sandi',
                obscure: _hide,
                onToggleObscure: () => setState(() => _hide = !_hide),
                action: TextInputAction.done,
                status: _pwStatus,
                error: _pwError,
                onChanged: (_) => setState(() => _failMsg = null),
                onBlur: () => setState(() => _touched.add('pw')),
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 28),
              PillButton('Masuk', loading: _loading, onPressed: _submit),
              const SizedBox(height: 18),
              TextButton(
                onPressed: () => authSnack(context, 'Fitur lupa kata sandi menyusul.'),
                child: const Text('Lupa kata sandi?',
                    style: TextStyle(
                        color: Colors.white, fontSize: 19, fontWeight: FontWeight.bold)),
              ),
            ]),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 24, top: 8),
          child: TextButton(
            onPressed: () => Navigator.maybePop(context), // kembali ke halaman Daftar
            child: const Text('Belum punya akun? Daftar',
                style: TextStyle(
                    color: Colors.white, fontSize: 19, fontWeight: FontWeight.bold)),
          ),
        ),
      ]),
    );
  }
}