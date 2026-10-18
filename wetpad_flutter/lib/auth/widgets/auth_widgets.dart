// lib/features/auth/widgets/auth_widgets.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme.dart';

const kRed = Color(0xFFFF5A36);
const kGreen = Color(0xFFA3C585);
const kPink = Color(0xFFFF7A8A);
const kTeal = Color(0xFF6CC3BB);
const kBorder = Color(0xFF4A4A4A);

enum FieldStatus { neutral, valid, error }

/// Logo teks sementara. Ganti dengan gambar logo kalau sudah ada.
class WetpadLogo extends StatelessWidget {
  final Color color;
  final double size;
  const WetpadLogo({super.key, required this.color, this.size = 52});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('wetpad',
              style: GoogleFonts.spaceGrotesk(
                  fontSize: size, fontWeight: FontWeight.w500, color: color)),
          SizedBox(width: size * 0.18),
          Text('w',
              style: GoogleFonts.nunito(
                  fontSize: size * 1.7,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                  color: color,
                  height: 1)),
        ],
      );
}

/// Kerangka halaman: lebar dibatasi supaya rapi juga di Chrome.
class AuthShell extends StatelessWidget {
  final Widget child;
  final Color background;
  const AuthShell({super.key, required this.child, this.background = AppColors.bg});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: background,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: child,
            ),
          ),
        ),
      );
}

class AuthTopBar extends StatelessWidget {
  final bool showClose;
  const AuthTopBar({super.key, this.showClose = false});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
        child: Row(children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, size: 30),
            onPressed: () => Navigator.maybePop(context),
          ),
          const Spacer(),
          if (showClose)
            IconButton(
              icon: const Icon(Icons.close, size: 30),
              onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
            ),
        ]),
      );
}

class PillButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading, outlined;
  final Widget? icon;
  const PillButton(this.label,
      {super.key, this.onPressed, this.loading = false, this.outlined = false, this.icon});

  @override
  Widget build(BuildContext context) {
    const text = TextStyle(fontSize: 18, fontWeight: FontWeight.bold);
    final child = loading
        ? SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
                strokeWidth: 2.4, color: outlined ? Colors.white : Colors.black))
        : Row(mainAxisSize: MainAxisSize.min, children: [
            if (icon != null) ...[icon!, const SizedBox(width: 12)],
            Text(label),
          ]);

    return SizedBox(
      height: 56,
      width: double.infinity,
      child: outlined
          ? OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white, width: 2),
                shape: const StadiumBorder(),
                textStyle: text,
              ),
              onPressed: onPressed,
              child: child,
            )
          : FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                disabledBackgroundColor: Colors.white24,
                disabledForegroundColor: Colors.white38,
                shape: const StadiumBorder(),
                textStyle: text,
              ),
              onPressed: onPressed,
              child: child,
            ),
    );
  }
}

void authSnack(BuildContext context, String msg) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      content: Text(msg, style: const TextStyle(color: Colors.black, fontSize: 18)),
    ));
}

/// Kolom isian berbentuk pil dengan label di garis border.
class AuthField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final FieldStatus status;
  final String? error, helper;
  final bool obscure, compact;
  final VoidCallback? onToggleObscure;
  final TextInputType? keyboard;
  final TextInputAction? action;
  final List<TextInputFormatter>? formatters;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onBlur;

  const AuthField({
    super.key,
    required this.controller,
    required this.label,
    this.status = FieldStatus.neutral,
    this.error,
    this.helper,
    this.obscure = false,
    this.compact = false,
    this.onToggleObscure,
    this.keyboard,
    this.action,
    this.formatters,
    this.onChanged,
    this.onSubmitted,
    this.onBlur,
  });

  @override
  State<AuthField> createState() => _AuthFieldState();
}

class _AuthFieldState extends State<AuthField> {
  final FocusNode _focus = FocusNode();
  bool _hadFocus = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(_onFocus);
  }

  void _onFocus() {
    if (_focus.hasFocus) {
      _hadFocus = true;
    } else if (_hadFocus) {
      widget.onBlur?.call();
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _focus.removeListener(_onFocus);
    _focus.dispose();
    super.dispose();
  }

  Widget? _suffix() {
    final items = <Widget>[];
    if (widget.status == FieldStatus.valid) {
      items.add(Icon(Icons.check, color: kGreen, size: widget.compact ? 20 : 26));
    }
    if (widget.onToggleObscure != null) {
      items.add(IconButton(
        icon: Icon(
            widget.obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            size: 28),
        onPressed: widget.onToggleObscure,
      ));
    }
    if (items.isEmpty) return null;
    return Padding(
      padding: EdgeInsets.only(right: widget.compact ? 8 : 12),
      child: Row(mainAxisSize: MainAxisSize.min, children: items),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.status;
    final focused = _focus.hasFocus;
    final color = s == FieldStatus.error
        ? kRed
        : s == FieldStatus.valid
            ? kGreen
            : (focused ? Colors.white : kBorder);
    final labelColor = s == FieldStatus.error
        ? kRed
        : s == FieldStatus.valid
            ? kGreen
            : (focused ? Colors.white : AppColors.muted);
    final w = (focused || s != FieldStatus.neutral) ? 2.0 : 1.2;
    OutlineInputBorder border() => OutlineInputBorder(
          borderRadius: BorderRadius.circular(40),
          borderSide: BorderSide(color: color, width: w),
        );

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      TextField(
        controller: widget.controller,
        focusNode: _focus,
        obscureText: widget.obscure,
        keyboardType: widget.keyboard,
        textInputAction: widget.action,
        inputFormatters: widget.formatters,
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
        cursorColor: Colors.white,
        style: const TextStyle(fontSize: 18),
        decoration: InputDecoration(
          labelText: widget.label,
          labelStyle: TextStyle(color: labelColor, fontSize: 18),
          floatingLabelStyle: TextStyle(color: labelColor, fontSize: 18),
          contentPadding: EdgeInsets.symmetric(
              horizontal: widget.compact ? 20 : 28, vertical: 20),
          border: border(),
          enabledBorder: border(),
          focusedBorder: border(),
          suffixIcon: _suffix(),
          suffixIconConstraints:
              widget.compact ? const BoxConstraints(minWidth: 0, minHeight: 0) : null,
        ),
      ),
      if (widget.error != null)
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
          child: Text(widget.error!, style: const TextStyle(color: kRed, fontSize: 15)),
        )
      else if (widget.helper != null)
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
          child: Text(widget.helper!,
              style: const TextStyle(color: AppColors.muted, fontSize: 15, height: 1.4)),
        ),
    ]);
  }
}

/// Pilihan berbentuk pil (untuk "Kata ganti").
class AuthSelect extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> options;
  final ValueChanged<String?> onChanged;
  const AuthSelect({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  Future<void> _open(BuildContext context) async {
    final v = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: const Color(0xFF1C1C1C),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: 12),
          for (final o in options)
            ListTile(
              title: Text(o, style: const TextStyle(fontSize: 19)),
              trailing: o == value ? const Icon(Icons.check, color: kGreen) : null,
              onTap: () => Navigator.pop(ctx, o),
            ),
          ListTile(
            title: const Text('Tidak menyebutkan',
                style: TextStyle(fontSize: 19, color: AppColors.muted)),
            onTap: () => Navigator.pop(ctx, ''),
          ),
          const SizedBox(height: 8),
        ]),
      ),
    );
    if (v != null) onChanged(v.isEmpty ? null : v);
  }

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border() => OutlineInputBorder(
          borderRadius: BorderRadius.circular(40),
          borderSide: const BorderSide(color: kBorder, width: 1.2),
        );
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _open(context),
      child: InputDecorator(
        isEmpty: value == null,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.muted, fontSize: 18),
          floatingLabelStyle: const TextStyle(color: AppColors.muted, fontSize: 18),
          contentPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
          border: border(),
          enabledBorder: border(),
          suffixIcon: const Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.keyboard_arrow_down, size: 32),
          ),
        ),
        child: Text(value ?? '', style: const TextStyle(fontSize: 18)),
      ),
    );
  }
}