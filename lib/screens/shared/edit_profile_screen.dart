import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../config/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_button.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    _nameController = TextEditingController(text: user?.name ?? '');
    _selectedCategory = user?.category;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final user = auth.currentUser!;

    final Map<String, dynamic> data = {};

    final newName = _nameController.text.trim();
    if (newName != user.name) {
      data['name'] = newName;
    }

    if (user.role == AppConstants.roleArtist &&
        _selectedCategory != user.category) {
      data['category'] = _selectedCategory;
    }

    if (data.isEmpty) {
      Navigator.pop(context);
      return;
    }

    final success = await auth.updateProfile(data);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated!'),
          backgroundColor: AppTheme.successColor,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update profile'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthProvider>().currentUser;
    final isArtist = user?.role == AppConstants.roleArtist;

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                controller: _nameController,
                label: 'Name',
                hintText: 'Enter your name',
                prefixIcon: const Icon(Icons.person_outline),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Email (read-only)
              CustomTextField(
                controller: TextEditingController(text: user?.email ?? ''),
                label: 'Email',
                hintText: '',
                prefixIcon: const Icon(Icons.email_outlined),
                readOnly: true,
              ),

              if (isArtist) ...[
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: AppConstants.categories
                      .map((cat) =>
                          DropdownMenuItem(value: cat, child: Text(cat)))
                      .toList(),
                  onChanged: (val) =>
                      setState(() => _selectedCategory = val),
                  validator: (val) =>
                      val == null ? 'Please select a category' : null,
                ),
              ],

              const SizedBox(height: 32),

              Consumer<AuthProvider>(
                builder: (_, auth, __) => CustomButton(
                  label: 'Save Changes',
                  onPressed: _save,
                  isLoading: auth.isLoading,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
