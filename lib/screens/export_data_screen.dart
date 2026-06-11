import 'package:flutter/material.dart';

import '../services/export_service.dart';
import '../widgets/section_title.dart';

class ExportDataScreen extends StatefulWidget {
  const ExportDataScreen({super.key});

  @override
  State<ExportDataScreen> createState() => _ExportDataScreenState();
}

class _ExportDataScreenState extends State<ExportDataScreen> {
  final _doctorEmailController = TextEditingController();
  int _days = 90;
  bool _loading = false;

  @override
  void dispose() {
    _doctorEmailController.dispose();
    super.dispose();
  }

  Future<void> _shareCsv() async {
    setState(() => _loading = true);
    try {
      await ExportService.shareHealthData(days: _days);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã mở bảng chia sẻ file CSV.')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Không thể export CSV: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openEmail() async {
    final email = _doctorEmailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nhập email bác sĩ trước nhé.')));
      return;
    }

    setState(() => _loading = true);
    try {
      await ExportService.openDoctorEmail(doctorEmail: email, days: _days);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Không mở được email: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Export / gửi bác sĩ')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        children: [
          const SectionTitle(
            title: 'Chia sẻ dữ liệu sức khỏe',
            subtitle: 'Xuất nhật ký sức khỏe + huyết áp thành file CSV để gửi qua Gmail, Outlook, Zalo hoặc lưu lại.',
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                        foregroundColor: Theme.of(context).colorScheme.primary,
                        child: const Icon(Icons.ios_share_outlined),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'File CSV gồm steps, calories, nước, cân nặng, giấc ngủ, nhịp tim, ghi chú và huyết áp.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    value: _days,
                    decoration: const InputDecoration(
                      labelText: 'Khoảng thời gian export',
                      prefixIcon: Icon(Icons.date_range_outlined),
                    ),
                    items: const [
                      DropdownMenuItem(value: 7, child: Text('7 ngày gần nhất')),
                      DropdownMenuItem(value: 14, child: Text('14 ngày gần nhất')),
                      DropdownMenuItem(value: 30, child: Text('30 ngày gần nhất')),
                      DropdownMenuItem(value: 90, child: Text('90 ngày gần nhất')),
                      DropdownMenuItem(value: 180, child: Text('180 ngày gần nhất')),
                    ],
                    onChanged: (value) => setState(() => _days = value ?? 90),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _loading ? null : _shareCsv,
                    icon: const Icon(Icons.attach_file_outlined),
                    label: Text(_loading ? 'Đang xử lý...' : 'Tạo file CSV & chia sẻ'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const SectionTitle(
            title: 'Soạn email cho bác sĩ',
            subtitle: 'Tính năng này mở app email với nội dung tóm tắt. Muốn gửi file đính kèm, bấm nút CSV ở trên rồi chọn Gmail/Email.',
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  TextField(
                    controller: _doctorEmailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email bác sĩ',
                      hintText: 'doctor@example.com',
                      prefixIcon: Icon(Icons.medical_information_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: _loading ? null : _openEmail,
                    icon: const Icon(Icons.mail_outline),
                    label: const Text('Soạn email tóm tắt'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Gợi ý dùng: bấm “Tạo file CSV & chia sẻ” → chọn Gmail → nhập email bác sĩ. File CSV sẽ được đính kèm để bác sĩ mở bằng Excel/Google Sheets.',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
