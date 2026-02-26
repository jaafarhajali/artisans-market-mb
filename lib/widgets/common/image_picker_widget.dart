import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/app_theme.dart';
import '../../services/storage_service.dart';

class ImagePickerWidget extends StatefulWidget {
  final String? initialUrl;
  final void Function(void, String? url) onImageSelected;

  const ImagePickerWidget({
    super.key,
    this.initialUrl,
    required this.onImageSelected,
  });

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  String? _imageUrl;
  bool _isUploading = false;
  final _storageService = StorageService();
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _imageUrl = widget.initialUrl;
  }

  void _showPickerOptions() {
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
                'Add Image',
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
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading:
                    const Icon(Icons.photo_library, color: AppTheme.primary),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.link, color: AppTheme.primary),
                title: const Text('Enter URL'),
                onTap: () {
                  Navigator.pop(ctx);
                  _enterUrl();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      if (picked == null) return;

      setState(() => _isUploading = true);

      final file = File(picked.path);
      final url = await _storageService.uploadPostImage(file);

      if (!mounted) return;

      if (url != null) {
        setState(() {
          _imageUrl = url;
          _isUploading = false;
        });
        widget.onImageSelected(null, url);
      } else {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to upload image. Please try again.'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not pick image. Please try again.'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  void _enterUrl() {
    final controller = TextEditingController(text: _imageUrl);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Enter Image URL'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'https://example.com/image.jpg',
          ),
          keyboardType: TextInputType.url,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final url = controller.text.trim();
              if (url.isNotEmpty) {
                setState(() {
                  _imageUrl = url;
                });
                widget.onImageSelected(null, url);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _isUploading ? null : _showPickerOptions,
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderColor, width: 2),
        ),
        clipBehavior: Clip.antiAlias,
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (_isUploading) {
      return const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppTheme.primary),
          SizedBox(height: 12),
          Text(
            'Uploading image...',
            style: TextStyle(color: AppTheme.textLight),
          ),
        ],
      );
    }

    if (_imageUrl != null && _imageUrl!.isNotEmpty) {
      return Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl: _imageUrl!,
            fit: BoxFit.cover,
            placeholder: (_, __) => const Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            ),
            errorWidget: (_, __, ___) => const Center(
              child: Icon(Icons.broken_image,
                  size: 48, color: AppTheme.textLight),
            ),
          ),
          _buildEditOverlay(),
        ],
      );
    }

    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_photo_alternate, size: 48, color: AppTheme.textLight),
        SizedBox(height: 8),
        Text(
          'Tap to add an image',
          style: TextStyle(color: AppTheme.textLight),
        ),
        Text(
          'Camera, Gallery, or URL',
          style: TextStyle(color: AppTheme.borderColor, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildEditOverlay() {
    return Positioned(
      bottom: 8,
      right: 8,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.edit, color: Colors.white, size: 20),
      ),
    );
  }
}
