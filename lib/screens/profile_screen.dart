import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/health_service.dart';
import '../services/storage_service.dart';
import '../widgets/section_title.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController(text: '20');
  final _heightController = TextEditingController(text: '170');
  final _goalController = TextEditingController(text: 'Giữ sức khỏe và vận động đều đặn');
  final _goalStepsController = TextEditingController(text: '10000');
  final _goalWaterController = TextEditingController(text: '2000');
  final _goalSleepController = TextEditingController(text: '8');
  final _goalCaloriesController = TextEditingController(text: '2200');
  bool _isSaving = false;
  bool _isUploading = false;
  bool _profileLoaded = false;
  String? _avatarUrl;

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _goalController.dispose();
    _goalStepsController.dispose();
    _goalWaterController.dispose();
    _goalSleepController.dispose();
    _goalCaloriesController.dispose();
    super.dispose();
  }

  void _fillForm(DocumentSnapshot<Map<String, dynamic>> doc) {
    if (_profileLoaded) return;
    final data = doc.data() ?? {};
    _nameController.text = data['name'] as String? ?? FirebaseAuth.instance.currentUser?.displayName ?? '';
    _ageController.text = '${(data['age'] as num?)?.toInt() ?? 20}';
    _heightController.text = '${(data['heightCm'] as num?)?.toDouble() ?? 170}';
    _goalController.text = data['goal'] as String? ?? 'Giữ sức khỏe và vận động đều đặn';
    _goalStepsController.text = '${(data['goalSteps'] as num?)?.toInt() ?? 10000}';
    _goalWaterController.text = '${(data['goalWaterMl'] as num?)?.toInt() ?? 2000}';
    _goalSleepController.text = '${(data['goalSleepHours'] as num?)?.toDouble() ?? 8}';
    _goalCaloriesController.text = '${(data['goalCalories'] as num?)?.toInt() ?? 2200}';
    setState(() {
      _avatarUrl = data['avatarUrl'] as String?;
      _profileLoaded = true;
    });
  }

  Future<void> _pickAndUploadAvatar() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80, maxWidth: 1200);
    if (picked == null) return;

    setState(() => _isUploading = true);
    try {
      final url = await StorageService.uploadAvatar(picked);
      setState(() => _avatarUrl = url);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Upload ảnh đại diện thành công')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload thất bại: $e')));
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      await HealthService.saveProfile(
        name: _nameController.text.trim(),
        age: int.parse(_ageController.text.trim()),
        heightCm: double.parse(_heightController.text.trim()),
        goal: _goalController.text.trim(),
        goalSteps: int.parse(_goalStepsController.text.trim()),
        goalWaterMl: int.parse(_goalWaterController.text.trim()),
        goalSleepHours: double.parse(_goalSleepController.text.trim()),
        goalCalories: int.parse(_goalCaloriesController.text.trim()),
        avatarUrl: _avatarUrl,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã lưu hồ sơ')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Không thể lưu hồ sơ: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String? _requiredNumber(String? value) {
    if (value == null || value.trim().isEmpty) return 'Không được bỏ trống';
    if (num.tryParse(value.trim()) == null) return 'Phải là số';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: HealthService.watchProfile(),
      builder: (context, snapshot) {
        if (snapshot.hasData && !_profileLoaded) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _fillForm(snapshot.data!));
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 56,
                          backgroundImage: _avatarUrl == null ? null : NetworkImage(_avatarUrl!),
                          child: _avatarUrl == null ? const Icon(Icons.person, size: 54) : null,
                        ),
                        CircleAvatar(
                          radius: 19,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            iconSize: 18,
                            onPressed: _isUploading ? null : _pickAndUploadAvatar,
                            icon: _isUploading
                                ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                                : const Icon(Icons.camera_alt),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(user?.email ?? '', style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 8),
                    const Chip(label: Text('Firebase profile + custom goals')),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const SectionTitle(title: 'Thông tin cá nhân'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: 'Họ tên', prefixIcon: Icon(Icons.person_outline)),
                        validator: (value) => value == null || value.trim().isEmpty ? 'Nhập họ tên' : null,
                      ),
                      const SizedBox(height: 12),
                      _NumberField(controller: _ageController, label: 'Tuổi', icon: Icons.cake_outlined, validator: _requiredNumber),
                      _NumberField(controller: _heightController, label: 'Chiều cao (cm)', icon: Icons.height, validator: _requiredNumber),
                      TextFormField(
                        controller: _goalController,
                        maxLines: 3,
                        decoration: const InputDecoration(labelText: 'Mục tiêu sức khỏe', prefixIcon: Icon(Icons.flag_outlined)),
                      ),
                      const SizedBox(height: 16),
                      const SectionTitle(title: 'Mục tiêu hằng ngày'),
                      _NumberField(controller: _goalStepsController, label: 'Bước chân mục tiêu', icon: Icons.directions_walk, validator: _requiredNumber),
                      _NumberField(controller: _goalWaterController, label: 'Nước uống mục tiêu (ml)', icon: Icons.water_drop_outlined, validator: _requiredNumber),
                      _NumberField(controller: _goalSleepController, label: 'Giờ ngủ mục tiêu', icon: Icons.bedtime_outlined, validator: _requiredNumber),
                      _NumberField(controller: _goalCaloriesController, label: 'Calories mục tiêu', icon: Icons.local_fire_department, validator: _requiredNumber),
                      const SizedBox(height: 18),
                      FilledButton.icon(
                        onPressed: _isSaving ? null : _save,
                        icon: const Icon(Icons.save),
                        label: Text(_isSaving ? 'Đang lưu...' : 'Lưu hồ sơ'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({required this.controller, required this.label, required this.icon, required this.validator});

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final FormFieldValidator<String> validator;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
        validator: validator,
      ),
    );
  }
}
