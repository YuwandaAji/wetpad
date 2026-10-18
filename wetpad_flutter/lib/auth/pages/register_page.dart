
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme.dart';
import '../services/auth_api.dart';
import '../widgets/auth_widgets.dart';
import 'password_page.dart';

const kMinAge = 13;
final _emailRe = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]{2,}$');
final _userRe = RegExp(r'^[A-Za-z0-9_]{3,20}$');

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _email = TextEditingController();
  final _user = TextEditingController();
  final _mm = TextEditingController();
  final _dd = TextEditingController();
  final _yy = TextEditingController();
  String? _pronoun;

  final Set<String> _touched = {};
  bool _submitted = false, _checking = false;
  Timer? _debounce;
  String? _checkedEmail, _checkedUser;
  bool _emailTaken = false, _userTaken = false;

  @override
  void dispose() {
    _debounce?.cancel();
    for (final c in [_email, _user, _mm, _dd, _yy]) {
      c.dispose();
    }
    super.dispose();
  }

  String get _e => _email.text.trim();
  String get _u => _user.text.trim();
  bool _show(String key) => _submitted || _touched.contains(key);

  // ---------- email & username ----------
  String? get _emailError {
    if (_e.isEmpty) return 'Email wajib diisi.';
    if (!_emailRe.hasMatch(_e)) return 'Ini bukan email yang valid.';
    if (_checkedEmail == _e && _emailTaken) return 'Email ini sudah terdaftar.';
    return null;
  }

  String? get _userError {
    if (_u.isEmpty) return 'Nama pengguna wajib diisi.';
    if (!_userRe.hasMatch(_u)) {
      return 'Gunakan 3-20 karakter: huruf, angka, atau garis bawah.';
    }
    if (_checkedUser == _u && _userTaken) return 'Nama pengguna ini sudah dipakai.';
    return null;
  }

  FieldStatus get _emailStatus {
    final takenNow = _checkedEmail == _e && _emailTaken;
    if (!_show('email') && !takenNow) return FieldStatus.neutral;
    if (_emailError != null) return FieldStatus.error;
    return _checkedEmail == _e ? FieldStatus.valid : FieldStatus.neutral;
  }

  FieldStatus get _userStatus {
    final takenNow = _checkedUser == _u && _userTaken;
    if (!_show('user') && !takenNow) return FieldStatus.neutral;
    if (_userError != null) return FieldStatus.error;
    return _checkedUser == _u ? FieldStatus.valid : FieldStatus.neutral;
  }

  void _scheduleCheck() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), _runCheck);
  }

  /// false kalau server tidak terjangkau.
  Future<bool> _runCheck() async {
    final e = _e, u = _u;
    final eOk = _emailRe.hasMatch(e), uOk = _userRe.hasMatch(u);
    if (!eOk && !uOk) return true;
    try {
      final r = await AuthApi.check(email: eOk ? e : null, username: uOk ? u : null);
      if (!mounted) return true;
      setState(() {
        if (eOk) {
          _checkedEmail = e;
          _emailTaken = r['email_taken'] == true;
        }
        if (uOk) {
          _checkedUser = u;
          _userTaken = r['username_taken'] == true;
        }
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  // ---------- tanggal lahir ----------
  DateTime? get _birth {
    final m = int.tryParse(_mm.text), d = int.tryParse(_dd.text), y = int.tryParse(_yy.text);
    if (m == null || d == null || y == null || _yy.text.length != 4) return null;
    final dt = DateTime(y, m, d);
    if (dt.year != y || dt.month != m || dt.day != d) return null; // mis. 31 Februari
    return dt;
  }

  bool get _mmOk {
    final m = int.tryParse(_mm.text);
    return m != null && m >= 1 && m <= 12;
  }

  bool get _ddOk {
    final d = int.tryParse(_dd.text);
    if (d == null || d < 1 || d > 31) return false;
    final m = int.tryParse(_mm.text), y = int.tryParse(_yy.text);
    if (m != null && m >= 1 && m <= 12 && y != null && _yy.text.length == 4) {
      return d <= DateTime(y, m + 1, 0).day;
    }
    return true;
  }

  bool get _yyOk {
    final y = int.tryParse(_yy.text);
    if (y == null || _yy.text.length != 4 || y < 1900 || y > DateTime.now().year) {
      return false;
    }
    final b = _birth;
    return b == null || !b.isAfter(DateTime.now());
  }

  bool get _underAge {
    final b = _birth;
    if (b == null || !_yyOk) return false;
    final now = DateTime.now();
    var age = now.year - b.year;
    if (now.month < b.month || (now.month == b.month && now.day < b.day)) age--;
    return age < kMinAge;
  }

  bool get _allValid =>
      _emailError == null &&
      _userError == null &&
      _checkedEmail == _e &&
      _checkedUser == _u &&
      _mmOk &&
      _ddOk &&
      _yyOk &&
      _birth != null &&
      !_underAge;

  // ---------- aksi ----------
  Future<void> _continue() async {
    if (_checking) return;
    _debounce?.cancel();
    setState(() {
      _submitted = true;
      _checking = true;
    });
    final reachable = await _runCheck();
    if (!mounted) return;
    setState(() => _checking = false);
    if (!reachable) {
      authSnack(context, 'Tidak bisa terhubung ke server.');
      return;
    }
    if (!_allValid) {
      authSnack(context, 'Harap perbaiki semua kesalahan untuk melanjutkan.');
      return;
    }

    final b = _birth!;
    final birth =
        '${b.year.toString().padLeft(4, '0')}-${b.month.toString().padLeft(2, '0')}-${b.day.toString().padLeft(2, '0')}';
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PasswordPage(
          data: RegisterData(email: _e, username: _u, birthDate: birth, pronoun: _pronoun),
        ),
      ),
    );
  }

  // ---------- UI ----------
  Widget _dobField(String label, TextEditingController c, String key, int max, bool ok,
      {bool forceError = false}) {
    final status = !_show(key)
        ? FieldStatus.neutral
        : (ok && !forceError ? FieldStatus.valid : FieldStatus.error);
    return AuthField(
      controller: c,
      label: label,
      status: status,
      compact: true,
      keyboard: TextInputType.number,
      formatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(max)],
      onChanged: (_) => setState(() {}),
      onBlur: () => setState(() => _touched.add(key)),
    );
  }

  bool get _dobHasError =>
      (_show('mm') && !_mmOk) ||
      (_show('dd') && !_ddOk) ||
      (_show('yy') && (!_yyOk || _underAge));

  Widget _dobMessage() {
    String text = 'Tanggal lahirmu hanya dapat dilihat oleh kamu dan tim pendukung Wetpad.';
    Color color = AppColors.muted;
    if (_underAge && _show('yy')) {
      text = 'Kamu harus berusia minimal $kMinAge tahun.';
      color = kRed;
    } else if (_dobHasError) {
      text = 'Harap perbaiki semua kesalahan untuk melanjutkan.';
      color = kRed;
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 10, 28, 0),
      child: Text(text, style: TextStyle(color: color, fontSize: 15, height: 1.4)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      child: Column(children: [
        const AuthTopBar(),
        Expanded(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Ceritakan tentang dirimu',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(height: 32),
              AuthField(
                controller: _email,
                label: 'Email',
                keyboard: TextInputType.emailAddress,
                status: _emailStatus,
                error: _emailStatus == FieldStatus.error ? _emailError : null,
                onChanged: (_) {
                  setState(() {});
                  _scheduleCheck();
                },
                onBlur: () {
                  setState(() => _touched.add('email'));
                  _runCheck();
                },
              ),
              const SizedBox(height: 20),
              AuthField(
                controller: _user,
                label: 'Nama Pengguna',
                status: _userStatus,
                error: _userStatus == FieldStatus.error ? _userError : null,
                helper: _userStatus == FieldStatus.valid
                    ? 'Kamu tidak harus menggunakan nama asli. Kamu dapat menggunakan nama lain untuk melindungi privasimu.'
                    : null,
                onChanged: (_) {
                  setState(() {});
                  _scheduleCheck();
                },
                onBlur: () {
                  setState(() => _touched.add('user'));
                  _runCheck();
                },
              ),
              const SizedBox(height: 28),
              const Text('Kapan kamu lahir?', style: TextStyle(fontSize: 19)),
              const SizedBox(height: 12),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(flex: 4, child: _dobField('MM', _mm, 'mm', 2, _mmOk)),
                const SizedBox(width: 12),
                Expanded(flex: 4, child: _dobField('DD', _dd, 'dd', 2, _ddOk)),
                const SizedBox(width: 12),
                Expanded(
                    flex: 5,
                    child: _dobField('YYYY', _yy, 'yy', 4, _yyOk, forceError: _underAge)),
              ]),
              _dobMessage(),
              const SizedBox(height: 28),
              AuthSelect(
                label: 'Kata ganti (opsional)',
                value: _pronoun,
                options: const ['Perempuan', 'Laki-laki', 'Netral'],
                onChanged: (v) => setState(() => _pronoun = v),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(24, 10, 24, 0),
                child: Text(
                  'Kata gantimu hanya dapat dilihat oleh kamu dan Tim Pendukung Wetpad. Kamu dapat memperbaruinya kapan saja di pengaturan.',
                  style: TextStyle(color: AppColors.muted, fontSize: 15, height: 1.4),
                ),
              ),
            ]),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
          child: PillButton('Lanjutkan', loading: _checking, onPressed: _continue),
        ),
      ]),
    );
  }
}