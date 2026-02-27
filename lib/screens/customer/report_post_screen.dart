import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/report_provider.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_button.dart';

class ReportPostScreen extends StatefulWidget {
  final String postId;

  const ReportPostScreen({super.key, required this.postId});

  @override
  State<ReportPostScreen> createState() => _ReportPostScreenState();
}

class _ReportPostScreenState extends State<ReportPostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final reporterId = context.read<AuthProvider>().currentUser!.uid;
    final success = await context.read<ReportProvider>().submitReport(
      postId: widget.postId,
      reporterId: reporterId,
      reason: _reasonController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Report submitted successfully. Thank you!'),
          backgroundColor: AppTheme.successColor,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to submit report'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report Post')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.flag, size: 48, color: AppTheme.errorColor),
              const SizedBox(height: 16),
              const Text(
                'Why are you reporting this post?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please provide a detailed reason for your report. Our admin team will review it.',
                style: TextStyle(color: AppTheme.textLight, fontSize: 14),
              ),
              const SizedBox(height: 24),
              CustomTextField(
                controller: _reasonController,
                label: 'Reason',
                hintText: 'Describe the issue...',
                maxLines: 5,
                maxLength: 500,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please provide a reason';
                  }
                  if (value.trim().length < 10) {
                    return 'Please provide more detail (at least 10 characters)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Consumer<ReportProvider>(
                builder: (_, prov, _) => CustomButton(
                  label: 'Submit Report',
                  onPressed: _submit,
                  isLoading: prov.isLoading,
                  color: AppTheme.errorColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
