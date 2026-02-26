import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/app_theme.dart';
import '../../config/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../services/storage_service.dart';
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
  String? _profileImageUrl;
  bool _isUploadingImage = false;
  final _storageService = StorageService();
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    _nameController = TextEditingController(text: user?.name ?? '');
    _selectedCategory = user?.category;
    _profileImageUrl = user?.profileImageUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Profile Photo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: AppTheme.primary),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickProfileImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading:
                    const Icon(Icons.photo_library, color: AppTheme.primary),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickProfileImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickProfileImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
      if (picked == null) return;

      setState(() => _isUploadingImage = true);

      final user = context.read<AuthProvider>().currentUser;
      final file = File(picked.path);
      final url =
          await _storageService.uploadProfileImage(file, user?.uid ?? '');

      if (!mounted) return;

      if (url != null) {
        setState(() {
          _profileImageUrl = url;
          _isUploadingImage = false;
        });
      } else {
        setState(() => _isUploadingImage = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to upload image. Please try again.'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isUploadingImage = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not pick image. Please try again.'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
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

    if (_profileImageUrl != user.profileImageUrl) {
      data['profileImageUrl'] = _profileImageUrl;
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

  Widget _buildProfileImage() {
    final user = context.read<AuthProvider>().currentUser;
    final initial =
        (user?.name.isNotEmpty ?? false) ? user!.name[0].toUpperCase() : '?';

    return GestureDetector(
      onTap: _isUploadingImage ? null : _showImageOptions,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (_isUploadingImage)
            CircleAvatar(
              radius: 52,
              backgroundColor: AppTheme.primary.withValues(alpha: 0.15),
              child:
                  const CircularProgressIndicator(color: AppTheme.primary),
            )
          else if (_profileImageUrl != null && _profileImageUrl!.isNotEmpty)
            CircleAvatar(
              radius: 52,
              backgroundColor: AppTheme.primary.withValues(alpha: 0.15),
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl: _profileImageUrl!,
                  width: 104,
                  height: 104,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => const CircularProgressIndicator(
                      color: AppTheme.primary),
                  errorWidget: (_, __, ___) => Text(
                    initial,
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
              ),
            )
          else
            CircleAvatar(
              radius: 52,
              backgroundColor: AppTheme.primary.withValues(alpha: 0.15),
              child: Text(
                initial,
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary,
                ),
              ),
            ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child:
                  const Icon(Icons.camera_alt, color: Colors.white, size: 16),
            ),
          ),
        ],
      ),
    );
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
              // Profile Image
              Center(child: _buildProfileImage()),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  'Tap to change photo',
                  style: TextStyle(color: AppTheme.textLight, fontSize: 12),
                ),
              ),
              const SizedBox(height: 24),

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
