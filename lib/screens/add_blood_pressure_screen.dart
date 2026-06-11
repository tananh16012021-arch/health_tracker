import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/blood_pressure_entry.dart';
import '../services/health_service.dart';

class AddBloodPressureScreen extends StatefulWidget {
  const AddBloodPressureScreen({super.key, this.entry});

  final BloodPressureEntry? entry;

  @override
  State<AddBloodPressureScreen> createState() => _AddBloodPressureScreenState();
}

class _AddBloodPressureScreenState extends State<AddBloodPressureScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _systolicController;
  late final TextEditingController _diastolicController;
  late final TextEditingController _pulseController;
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
    _mood = entry?.mood ?? 'Bình thường';
    _systolicController = TextEditingController(text: '${entry?.systolic ?? 120}');
    _diastolicController = TextEditingController(text: '${entry?.diastolic ?? 80}');
    _pulseController = TextEditingController(text: '${entry?.pulse ?? 72}');
    _noteController = TextEditingController(text: entry?.note ?? '');
  }

  @override
  void dispose() {
    _systolicController.dispose();
    _diastolicController.dispose();
    _pulseController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      initialDate: _date,
    );
    if (pickedDate == null || !mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_date),
    );
    if (pickedTime == null) return;

    setState(() {
      _date = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final systolic = int.parse(_systolicController.text.trim());
    final diastolic = int.parse(_diastolicController.text.trim());
    if (diastolic >= systolic) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tâm trương nên nhỏ hơn tâm thu.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final entry = BloodPressureEntry(
        id: widget.entry?.id,
        userId: HealthService.currentUserId,
        systolic: systolic,
        diastolic: diastolic,
        pulse: int.parse(_pulseController.text.trim()),
        date: _date,
        mood: _mood,
        note: _noteController.text.trim(),
      );

      await HealthService.upsertBloodPressureEntry(entry);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Không thể lưu huyết áp: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String? _requiredIntInRange(String? value, int min, int max) {
    if (value == null || value.trim().isEmpty) return 'Không được bỏ trống';
    final number = int.tryParse(value.trim());
    if (number == null) return 'Phải là số nguyên';
    if (number < min || number > max) return 'Nhập trong khoảng $min - $max';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final dateText = DateFormat('dd/MM/yyyy HH:mm').format(_date);

    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Sửa huyết áp' : 'Thêm huyết áp')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.event_available_outlined),
                title: const Text('Thời gian đo'),
                subtitle: Text(dateText),
                trailing: const Icon(Icons.edit_calendar),
                onTap: _pickDateTime,
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _mood,
              decoration: const InputDecoration(
                labelText: 'Tình trạng khi đo',
                prefixIcon: Icon(Icons.mood_outlined),
              ),
              items: const [
                DropdownMenuItem(value: 'Bình thường', child: Text('Bình thường')),
                DropdownMenuItem(value: 'Căng thẳng', child: Text('Căng thẳng')),
                DropdownMenuItem(value: 'Đau đầu', child: Text('Đau đầu')),
                DropdownMenuItem(value: 'Chóng mặt', child: Text('Chóng mặt')),
                DropdownMenuItem(value: 'Sau vận động', child: Text('Sau vận động')),
              ],
              onChanged: (value) => setState(() => _mood = value ?? 'Bình thường'),
            ),
            const SizedBox(height: 12),
            _NumberField(
              controller: _systolicController,
              label: 'Tâm thu - Systolic (mmHg)',
              icon: Icons.arrow_upward,
              validator: (value) => _requiredIntInRange(value, 70, 250),
            ),
            _NumberField(
              controller: _diastolicController,
              label: 'Tâm trương - Diastolic (mmHg)',
              icon: Icons.arrow_downward,
              validator: (value) => _requiredIntInRange(value, 40, 160),
            ),
            _NumberField(
              controller: _pulseController,
              label: 'Nhịp tim - Pulse (bpm)',
              icon: Icons.favorite_border,
              validator: (value) => _requiredIntInRange(value, 35, 220),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _noteController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Ghi chú / triệu chứng',
                prefixIcon: Icon(Icons.note_alt_outlined),
              ),
            ),
            const SizedBox(height: 16),
            _HintCard(
              systolicText: _systolicController.text,
              diastolicText: _diastolicController.text,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _isLoading ? null : _save,
              icon: const Icon(Icons.save),
              label: Text(_isLoading ? 'Đang lưu...' : (_isEditing ? 'Cập nhật' : 'Lưu huyết áp')),
            ),
          ],
        ),
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.validator,
  });

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
        keyboardType: TextInputType.number,
        decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
        validator: validator,
      ),
    );
  }
}

class _HintCard extends StatelessWidget {
  const _HintCard({required this.systolicText, required this.diastolicText});

  final String systolicText;
  final String diastolicText;

  @override
  Widget build(BuildContext context) {
    final systolic = int.tryParse(systolicText.trim()) ?? 0;
    final diastolic = int.tryParse(diastolicText.trim()) ?? 0;
    final isHigh = systolic >= 140 || diastolic >= 90;
    final message = isHigh
        ? 'Nếu nhiều lần đo vẫn ≥ 140/90 mmHg, app sẽ đánh dấu cảnh báo đỏ. Hãy nghỉ 5 phút rồi đo lại và cân nhắc hỏi bác sĩ nếu triệu chứng nặng.'
        : 'Mốc cảnh báo trong app: tâm thu ≥ 140 hoặc tâm trương ≥ 90 mmHg.';

    return Card(
      color: isHigh ? const Color(0xFFFFEBEE) : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(isHigh ? Icons.warning_amber_rounded : Icons.info_outline, color: isHigh ? Colors.red : Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }
}
