
import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../services/auth_api.dart';
import '../widgets/auth_widgets.dart';
import 'genre_page.dart';

class PasswordPage extends StatefulWidget {
  final RegisterData data;
  const PasswordPage({super.key, required this.data});

  @override
  State<PasswordPage> createState() => _PasswordPageState();
}

class _PasswordPageState extends State<PasswordPage> {
  final _pw = TextEditingController();
  final _pw2 = TextEditingController();
  bool _hide1 = true, _hide2 = true;
  bool _touchedPw = false, _touchedPw2 = false, _submitted = false;
  bool _promo = false, _terms = false, _loading = false;

  @override
  void dispose() {
    _pw.dispose();
    _pw2.dispose();
    super.dispose();
  }

  bool get _pwOk {
    final v = _pw.text;
    return v.length >= 10 &&
        RegExp(r'[0-9]').hasMatch(v) &&
        RegExp(r'[a-z]').hasMatch(v) &&
        RegExp(r'[A-Z]').hasMatch(v) &&
        RegExp(r'[^A-Za-z0-9]').hasMatch(v) &&
        !v.toLowerCase().contains(widget.data.username.toLowerCase());
  }

  bool get _pw2Ok => _pw2.text.isNotEmpty && _pw2.text == _pw.text;

  bool get _showPwState => _touchedPw || _submitted;
  bool get _showPw2State => _touchedPw2 || _submitted;

  FieldStatus get _pwStatus => _pwOk
      ? FieldStatus.valid
      : (_showPwState ? FieldStatus.error : FieldStatus.neutral);

  FieldStatus get _pw2Status => _pw2Ok
      ? FieldStatus.valid
      : (_showPw2State ? FieldStatus.error : FieldStatus.neutral);

  Future<void> _submit() async {
    if (_loading) return;
    setState(() => _submitted = true);
    if (!_pwOk || !_pw2Ok || !_terms) {
      authSnack(context, 'Harap perbaiki semua kesalahan untuk melanjutkan.');
      return;
    }
    setState(() => _loading = true);
    try {
      await AuthApi.register(data: widget.data, password: _pw.text, newsletter: _promo);
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
          context, MaterialPageRoute(builder: (_) => const GenrePage()), (_) => false);
    } on ApiException catch (e) {
      if (mounted) {
        authSnack(context, e.fields.isNotEmpty ? e.fields.values.first : e.message);
      }
    } catch (_) {
      if (mounted) authSnack(context, 'Tidak bisa terhubung ke server.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _requirements(bool error) {
    final c = error ? kPink : const Color(0xFFB5B5B5);
    const rules = [
      'Harus mengandung angka, karakter khusus, serta huruf kecil dan huruf besar',
      'Minimal 10 karakter',
      'Tidak boleh mengandung nama pengguna atau namamu',
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(error ? 'Kata sandi kamu belum memenuhi persyaratan.' : 'Persyaratan kata sandi:',
            style: TextStyle(color: c, fontSize: 15)),
        for (final r in rules)
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('•  ', style: TextStyle(color: c, fontSize: 16)),
              Expanded(child: Text(r, style: TextStyle(color: c, fontSize: 16, height: 1.3))),
            ]),
          ),
      ]),
    );
  }

  Widget _checkRow({
    required bool value,
    required ValueChanged<bool> onChanged,
    required Widget label,
    String? error,
  }) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.only(top: 2, right: 14, left: 4),
        child: Transform.scale(
          scale: 1.3,
          child: Checkbox(
            value: value,
            onChanged: (v) => onChanged(v ?? false),
            side: const BorderSide(color: Colors.white, width: 2),
            activeColor: Colors.white,
            checkColor: Colors.black,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
          ),
        ),
      ),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          label,
          if (error != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(error, style: const TextStyle(color: kPink, fontSize: 16)),
            ),
        ]),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      child: Column(children: [
        const AuthTopBar(showClose: true),
        Expanded(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Buat Akun',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(height: 32),
              AuthField(
                controller: _pw,
                label: 'Kata sandi',
                obscure: _hide1,
                onToggleObscure: () => setState(() => _hide1 = !_hide1),
                status: _pwStatus,
                onChanged: (_) => setState(() {}),
                onBlur: () => setState(() => _touchedPw = true),
              ),
              if (_pwStatus != FieldStatus.valid)
                _requirements(_pwStatus == FieldStatus.error),
              const SizedBox(height: 24),
              AuthField(
                controller: _pw2,
                label: 'Masukkan kembali kata sandi',
                obscure: _hide2,
                onToggleObscure: () => setState(() => _hide2 = !_hide2),
                status: _pw2Status,
                error: _pw2Status == FieldStatus.error ? 'Kata sandi ini tidak cocok.' : null,
                onChanged: (_) => setState(() {}),
                onBlur: () => setState(() => _touchedPw2 = true),
              ),
              const SizedBox(height: 36),
              _checkRow(
                value: _promo,
                onChanged: (v) => setState(() => _promo = v),
                label: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Ya, saya ingin menerima email promosi dari Wetpad. (opsional)',
                      style: TextStyle(fontSize: 18, height: 1.35)),
                  SizedBox(height: 6),
                  Text(
                      'Dapatkan rekomendasi cerita, pengumuman, penawaran, dan lainnya melalui email. Berhenti berlangganan kapan saja.',
                      style: TextStyle(fontSize: 15, color: AppColors.muted, height: 1.5)),
                ]),
              ),
            ]),
          ),
        ),
        // ---- menempel di bawah, tepat di atas tombol Daftar ----
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            _checkRow(
              value: _terms,
              onChanged: (v) => setState(() => _terms = v),
              error: (_submitted && !_terms) ? 'Wajib mencentang kotak ini.' : null,
              label: const Text.rich(
                TextSpan(
                  style: TextStyle(fontSize: 18, height: 1.35),
                  children: [
                    TextSpan(text: 'Ya, saya telah membaca dan menyetujui '),
                    TextSpan(
                        text: 'Persyaratan Layanan',
                        style: TextStyle(color: kTeal, fontWeight: FontWeight.bold)),
                    TextSpan(text: ' dan '),
                    TextSpan(
                        text: 'Kebijakan Privasi',
                        style: TextStyle(color: kTeal, fontWeight: FontWeight.bold)),
                    TextSpan(text: ' Wetpad.'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            PillButton('Daftar', loading: _loading, onPressed: _submit),
          ]),
        ),
      ]),
    );
  }
}