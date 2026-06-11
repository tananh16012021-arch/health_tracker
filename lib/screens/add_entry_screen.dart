import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/health_entry.dart';
import '../services/health_service.dart';

class AddEntryScreen extends StatefulWidget {
  const AddEntryScreen({super.key, this.entry});

  final HealthEntry? entry;

  @override
  State<AddEntryScreen> createState() => _AddEntryScreenState();
}

class _AddEntryScreenState extends State<AddEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _stepsController;
  late final TextEditingController _caloriesController;
  late final TextEditingController _waterController;
  late final TextEditingController _weightController;
  late final TextEditingController _heartRateController;
  late final TextEditingController _sleepController;
  late final TextEditingController _workoutController;
  late final TextEditingController _proteinController;
  late final TextEditingController _noteController;
  late DateTime _date;
  late String _mood;
  bool _isLoading = false;

  bool get _isEditing => widget.entry != null;

  @override
  void initState() {
    super.initState();
    final entry = widget.entry;
    _date = entry?.date ?? DateTime.now();
    _mood = entry?.mood ?? 'Tốt';
    _stepsController = TextEditingController(text: '${entry?.steps ?? 6000}');
    _caloriesController = TextEditingController(text: '${entry?.calories ?? 1800}');
    _waterController = TextEditingController(text: '${entry?.waterMl ?? 1500}');
    _weightController = TextEditingController(text: '${entry?.weightKg ?? 60}');
    _heartRateController = TextEditingController(text: '${entry?.heartRate ?? 75}');
    _sleepController = TextEditingController(text: '${entry?.sleepHours ?? 7}');
    _workoutController = TextEditingController(text: '${entry?.workoutMinutes ?? 30}');
    _proteinController = TextEditingController(text: '${entry?.proteinGrams ?? 75}');
    _noteController = TextEditingController(text: entry?.note ?? '');
  }

  @override
  void dispose() {
    _stepsController.dispose();
    _caloriesController.dispose();
    _waterController.dispose();
    _weightController.dispose();
    _heartRateController.dispose();
    _sleepController.dispose();
    _workoutController.dispose();
    _proteinController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      initialDate: _date,
    );

    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final entry = HealthEntry(
        id: widget.entry?.id,
        date: _date,
        steps: int.parse(_stepsController.text.trim()),
        calories: int.parse(_caloriesController.text.trim()),
        waterMl: int.parse(_waterController.text.trim()),
        weightKg: double.parse(_weightController.text.trim()),
        heartRate: int.parse(_heartRateController.text.trim()),
        sleepHours: double.parse(_sleepController.text.trim()),
        workoutMinutes: int.parse(_workoutController.text.trim()),
        proteinGrams: int.parse(_proteinController.text.trim()),
        mood: _mood,
        note: _noteController.text.trim(),
      );

      await HealthService.upsertEntry(entry);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Không thể lưu: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String? _requiredNumber(String? value) {
    if (value == null || value.trim().isEmpty) return 'Không được bỏ trống';
    if (num.tryParse(value.trim()) == null) return 'Phải là số';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final dateText = DateFormat('dd/MM/yyyy').format(_date);

    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Sửa nhật ký' : 'Thêm nhật ký')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_month),
                title: const Text('Ngày ghi nhận'),
                subtitle: Text(dateText),
                trailing: const Icon(Icons.edit_calendar),
                onTap: _pickDate,
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _mood,
              decoration: const InputDecoration(
                labelText: 'Tâm trạng hôm nay',
                prefixIcon: Icon(Icons.mood_outlined),
              ),
              items: const [
                DropdownMenuItem(value: 'Tốt', child: Text('Tốt')),
                DropdownMenuItem(value: 'Bình thường', child: Text('Bình thường')),
                DropdownMenuItem(value: 'Mệt', child: Text('Mệt')),
                DropdownMenuItem(value: 'Rất khỏe', child: Text('Rất khỏe')),
              ],
              onChanged: (value) => setState(() => _mood = value ?? 'Tốt'),
            ),
            const SizedBox(height: 12),
            _NumberField(controller: _stepsController, label: 'Bước chân', icon: Icons.directions_walk, validator: _requiredNumber),
            _NumberField(controller: _caloriesController, label: 'Calories', icon: Icons.local_fire_department, validator: _requiredNumber),
            _NumberField(controller: _waterController, label: 'Lượng nước uống (ml)', icon: Icons.water_drop_outlined, validator: _requiredNumber),
            _NumberField(controller: _weightController, label: 'Cân nặng (kg)', icon: Icons.monitor_weight_outlined, validator: _requiredNumber),
            _NumberField(controller: _heartRateController, label: 'Nhịp tim (bpm)', icon: Icons.favorite_border, validator: _requiredNumber),
            _NumberField(controller: _sleepController, label: 'Thời gian ngủ (giờ)', icon: Icons.bedtime_outlined, validator: _requiredNumber),
            _NumberField(controller: _workoutController, label: 'Thời gian tập luyện (phút)', icon: Icons.fitness_center, validator: _requiredNumber),
            _NumberField(controller: _proteinController, label: 'Protein trong ngày (gram)', icon: Icons.egg_alt_outlined, validator: _requiredNumber),
            const SizedBox(height: 8),
            TextFormField(
              controller: _noteController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Ghi chú', prefixIcon: Icon(Icons.note_alt_outlined)),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _isLoading ? null : _save,
              icon: const Icon(Icons.save),
              label: Text(_isLoading ? 'Đang lưu...' : (_isEditing ? 'Cập nhật' : 'Lưu nhật ký')),
            ),
          ],
        ),
      ),
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
