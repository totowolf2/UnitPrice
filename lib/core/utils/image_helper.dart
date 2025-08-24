import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../constants/app_constants.dart';

class ImageHelper {
  static const String _imageFolder = AppConstants.imageFolder;
  
  /// Pick and save image from camera or gallery
  static Future<String?> pickAndSaveImage({
    bool fromCamera = false,
  }) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        maxWidth: AppConstants.maxImageWidth.toDouble(),
        maxHeight: AppConstants.maxImageHeight.toDouble(),
        imageQuality: AppConstants.imageQuality,
      );
      
      if (image == null) return null;
      
      // Get app documents directory
      final Directory appDir = await getApplicationDocumentsDirectory();
      final Directory imageDir = Directory('${appDir.path}/$_imageFolder');
      if (!await imageDir.exists()) {
        await imageDir.create(recursive: true);
      }
      
      // Generate unique filename
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String imagePath = '${imageDir.path}/$fileName';
      
      // Compress and save image
      final Uint8List? compressedImage = await FlutterImageCompress.compressWithFile(
        image.path,
        minWidth: AppConstants.compressedImageSize,
        minHeight: AppConstants.compressedImageSize,
        quality: AppConstants.compressQuality,
        format: CompressFormat.jpeg,
      );
      
      if (compressedImage != null) {
        final File savedImage = File(imagePath);
        await savedImage.writeAsBytes(compressedImage);
        return imagePath;
      }
      
      return null;
    } catch (error) {
      throw ImageException('Failed to pick and save image: $error');
    }
  }
  
  /// Delete image file
  static Future<void> deleteImage(String? imagePath) async {
    if (imagePath == null || imagePath.isEmpty) return;
    
    try {
      final File imageFile = File(imagePath);
      if (await imageFile.exists()) {
        await imageFile.delete();
      }
    } catch (error) {
      throw ImageException('Failed to delete image: $error');
    }
  }
  
  /// Check if image file exists
  static Future<bool> imageExists(String? imagePath) async {
    if (imagePath == null || imagePath.isEmpty) return false;
    
    try {
      final File imageFile = File(imagePath);
      return await imageFile.exists();
    } catch (error) {
      return false;
    }
  }
  
  /// Get image file size in bytes
  static Future<int?> getImageSize(String imagePath) async {
    try {
      final File imageFile = File(imagePath);
      if (await imageFile.exists()) {
        final stats = await imageFile.stat();
        return stats.size;
      }
      return null;
    } catch (error) {
      return null;
    }
  }
  
  /// Clean up orphaned images (images not referenced by any product)
  static Future<void> cleanupOrphanedImages(List<String> referencedImagePaths) async {
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final Directory imageDir = Directory('${appDir.path}/$_imageFolder');
      
      if (!await imageDir.exists()) return;
      
      final List<FileSystemEntity> files = await imageDir.list().toList();
      
      for (final file in files) {
        if (file is File) {
          final String imagePath = file.path;
          
          // Check if this image is referenced by any product
          final bool isReferenced = referencedImagePaths.contains(imagePath);
          
          if (!isReferenced) {
            await file.delete();
          }
        }
      }
    } catch (error) {
      throw ImageException('Failed to cleanup orphaned images: $error');
    }
  }
  
  /// Compress existing image file
  static Future<String?> compressImage(String imagePath) async {
    try {
      final File originalFile = File(imagePath);
      if (!await originalFile.exists()) {
        return null;
      }
      
      final Directory appDir = await getApplicationDocumentsDirectory();
      final Directory imageDir = Directory('${appDir.path}/$_imageFolder');
      if (!await imageDir.exists()) {
        await imageDir.create(recursive: true);
      }
      
      // Generate new filename for compressed image
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}_compressed.jpg';
      final String compressedPath = '${imageDir.path}/$fileName';
      
      final Uint8List? compressedImage = await FlutterImageCompress.compressWithFile(
        imagePath,
        minWidth: AppConstants.compressedImageSize,
        minHeight: AppConstants.compressedImageSize,
        quality: AppConstants.compressQuality,
        format: CompressFormat.jpeg,
      );
      
      if (compressedImage != null) {
        final File compressedFile = File(compressedPath);
        await compressedFile.writeAsBytes(compressedImage);
        
        // Delete original file if it's different from compressed file
        if (imagePath != compressedPath) {
          await originalFile.delete();
        }
        
        return compressedPath;
      }
      
      return null;
    } catch (error) {
      throw ImageException('Failed to compress image: $error');
    }
  }
  
  /// Get formatted file size string
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }
  
  /// Validate image path format
  static bool isValidImagePath(String? path) {
    if (path == null || path.isEmpty) return false;
    
    final validExtensions = ['.jpg', '.jpeg', '.png'];
    final lowercasePath = path.toLowerCase();
    
    return validExtensions.any((ext) => lowercasePath.endsWith(ext));
  }
}

/// Custom exception for image operations
class ImageException implements Exception {
  final String message;
  
  const ImageException(this.message);
  
  @override
  String toString() => 'ImageException: $message';
}