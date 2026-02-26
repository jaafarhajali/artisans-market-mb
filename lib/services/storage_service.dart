import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

class StorageService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Uploads an image file to Supabase Storage and returns the public URL.
  /// [file] - the image file to upload
  /// [folder] - subfolder in the bucket (e.g. 'posts', 'profiles')
  Future<String?> uploadImage(File file, String folder) async {
    try {
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = '$folder/$fileName';

      final bytes = await file.readAsBytes();

      await _client.storage
          .from(SupabaseConfig.bucketName)
          .uploadBinary(
            path,
            bytes,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: true,
            ),
          );

      final url = _client.storage
          .from(SupabaseConfig.bucketName)
          .getPublicUrl(path);

      debugPrint('StorageService upload success: $url');
      return url;
    } catch (e) {
      debugPrint('StorageService upload error: $e');
      return null;
    }
  }

  /// Upload a post image. Returns the public URL or null on failure.
  Future<String?> uploadPostImage(File file) async {
    return uploadImage(file, 'posts');
  }

  /// Upload a profile image. Returns the public URL or null on failure.
  Future<String?> uploadProfileImage(File file, String userId) async {
    return uploadImage(file, 'profiles');
  }
}
