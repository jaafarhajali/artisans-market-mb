import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../config/app_constants.dart';
import '../../models/post_model.dart';
import '../../providers/post_provider.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/image_picker_widget.dart';

class EditPostScreen extends StatefulWidget {
  final PostModel post;

  const EditPostScreen({super.key, required this.post});

  @override
  State<EditPostScreen> createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late String? _selectedCategory;
  String? _newImageUrl;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(
      text: widget.post.description,
    );
    _priceController = TextEditingController(
      text: widget.post.price > 0 ? widget.post.price.toStringAsFixed(2) : '',
    );
    _selectedCategory = widget.post.category;
    _newImageUrl = widget.post.imageUrl;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final Map<String, dynamic> data = {};

    if (_descriptionController.text.trim() != widget.post.description) {
      data['description'] = _descriptionController.text.trim();
    }
    if (_selectedCategory != widget.post.category) {
      data['category'] = _selectedCategory;
    }
    if (_newImageUrl != null && _newImageUrl != widget.post.imageUrl) {
      data['imageUrl'] = _newImageUrl;
    }
    final newPrice = double.tryParse(_priceController.text.trim()) ?? 0.0;
    if (newPrice != widget.post.price) {
      data['price'] = newPrice;
    }

    final success = await context.read<PostProvider>().updatePost(
      widget.post.id,
      data,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Post updated successfully!'),
          backgroundColor: AppTheme.successColor,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update post'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Post')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                initialUrl: widget.post.imageUrl,
                onImageSelected: (_, url) {
                  setState(() {
                    _newImageUrl = url;
                  });
                },
              ),
              const SizedBox(height: 20),

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

              Consumer<PostProvider>(
                builder: (_, prov, _) => CustomButton(
                  label: 'Save Changes',
                  icon: Icons.save,
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
