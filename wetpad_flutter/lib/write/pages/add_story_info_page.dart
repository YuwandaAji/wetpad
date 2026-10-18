import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme.dart';

class AddStoryInfoPage extends StatefulWidget {
  const AddStoryInfoPage({super.key});

  @override
  State<AddStoryInfoPage> createState() => _AddStoryInfoPageState();
}

class _AddStoryInfoPageState extends State<AddStoryInfoPage> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _picker = ImagePicker();
  Uint8List? _coverBytes;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickCover() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      imageQuality: 85,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    if (!mounted) return;
    setState(() => _coverBytes = bytes);
  }

  void _save() {
    if (_titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Judul cerita wajib diisi')));
      return;
    }
    // TODO: kirim judul, deskripsi, dan cover ke API
    // (menunggu endpoint dari backend)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cerita tersimpan (sementara)')),
    );
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
          'Add Story Info',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
        titleSpacing: 0,
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text(
              'SKIP',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                color: kGreyField,
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    InkWell(
                      onTap: _pickCover,
                      child: Container(
                        width: 82,
                        height: 130,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          color: kBg,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.white54),
                        ),
                        child: _coverBytes == null
                            ? const Icon(
                                Icons.add,
                                size: 36,
                                color: Colors.grey,
                              )
                            : Image.memory(_coverBytes!, fit: BoxFit.cover),
                      ),
                    ),
                    const SizedBox(width: 24),
                    GestureDetector(
                      onTap: _pickCover,
                      child: Text(
                        _coverBytes == null ? 'Add a cover' : 'Change cover',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              _underlineField(controller: _titleCtrl, hint: 'Story Title'),
              const SizedBox(height: 40),
              _underlineField(
                controller: _descCtrl,
                hint: 'Story Description',
                minLines: 5,
                maxLines: null,
                keyboardType: TextInputType.multiline,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
          child: SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: kOrange,
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
              ),
              child: const Text(
                'Simpan cerita',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _underlineField({
    required TextEditingController controller,
    required String hint,
    int minLines = 1,
    int? maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: TextField(
        controller: controller,
        minLines: minLines,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 18),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 18),
          isDense: true,
          contentPadding: const EdgeInsets.only(bottom: 8),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white70),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: kOrange),
          ),
        ),
      ),
    );
  }
}
