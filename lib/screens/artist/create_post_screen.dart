import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../config/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/post_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/image_picker_widget.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  String? _selectedCategory;
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = context.read<AuthProvider>().currentUser?.uid;
      if (uid != null) {
        context.read<SubscriptionProvider>().loadSubscription(uid);
      }
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_imageUrl == null || _imageUrl!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add an image URL'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final postProv = context.read<PostProvider>();
    final subProv = context.read<SubscriptionProvider>();
    final uid = auth.currentUser!.uid;
    final artistName = auth.currentUser!.name;

    // Check post limit
    final currentCount = await postProv.getActivePostCount(uid);
    final limit = subProv.subscription?.postLimit ?? 5;
    final isUnlimited = subProv.subscription?.isUnlimited ?? false;

    if (!isUnlimited && currentCount >= limit) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Post limit reached ($currentCount/$limit). Upgrade your plan for more posts.',
          ),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    final price = double.tryParse(_priceController.text.trim()) ?? 0.0;

    final success = await postProv.createPost(
      artistId: uid,
      artistName: artistName,
      description: _descriptionController.text.trim(),
      category: _selectedCategory!,
      price: price,
      imageUrl: _imageUrl,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Post created successfully!'),
          backgroundColor: AppTheme.successColor,
        ),
      );
      setState(() {
        _descriptionController.clear();
        _priceController.clear();
        _selectedCategory = null;
        _imageUrl = null;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to create post'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Post')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Post limit indicator
              Consumer<SubscriptionProvider>(
                builder: (_, subProv, _) {
                  if (subProv.isLoading) return const SizedBox.shrink();
                  final plan = subProv.subscription?.planDisplayName ?? 'Free';
                  final limit = subProv.subscription?.postLimit ?? 5;
                  final isUnlimited =
                      subProv.subscription?.isUnlimited ?? false;

                  return Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: AppTheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Plan: $plan — ${isUnlimited ? 'Unlimited posts' : 'Up to $limit posts'}',
                            style: const TextStyle(
                              color: AppTheme.textDark,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              // Image Picker
              const Text(
                'Post Image',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 8),
              ImagePickerWidget(
                onImageSelected: (_, url) {
                  setState(() {
                    _imageUrl = url;
                  });
                },
              ),
              const SizedBox(height: 20),

              // Category
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category),
                ),
                items: AppConstants.categories
                    .map(
                      (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
                    )
                    .toList(),
                onChanged: (val) => setState(() => _selectedCategory = val),
                validator: (val) =>
                    val == null ? 'Please select a category' : null,
              ),
              const SizedBox(height: 16),

              // Price
              TextFormField(
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Price (USD)',
                  prefixIcon: Icon(Icons.attach_money),
                  hintText: '0.00',
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final price = double.tryParse(value);
                    if (price == null || price < 0) {
                      return 'Please enter a valid price';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description
              CustomTextField(
                controller: _descriptionController,
                label: 'Description',
                hintText: 'Describe your artwork...',
                maxLines: 5,
                maxLength: 500,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please provide a description';
                  }
                  if (value.trim().length < 10) {
                    return 'Please provide more detail (at least 10 characters)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Submit
              Consumer<PostProvider>(
                builder: (_, prov, _) => CustomButton(
                  label: 'Create Post',
                  icon: Icons.publish,
                  onPressed: _submit,
                  isLoading: prov.isLoading,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
