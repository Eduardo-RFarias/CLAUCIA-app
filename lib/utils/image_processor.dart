import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class ImageProcessor {
  static final ImagePicker _picker = ImagePicker();

  /// Picks an image from the specified source, crops it to square aspect ratio,
  /// and resizes to 224x224 pixels for ML model compatibility.
  ///
  /// [source] - Camera or gallery
  /// [filePrefix] - Prefix for the saved file (e.g., 'wound', 'sample')
  ///
  /// Returns the path to the processed image file, or null if cancelled/failed.
  static Future<String?> pickAndProcessImage({
    required ImageSource source,
    required String filePrefix,
  }) async {
    try {
      // Pick image
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile == null) return null;

      // Crop and resize
      return await _cropAndResizeImage(pickedFile.path, filePrefix);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick image: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }
  }

  static Future<String?> _cropAndResizeImage(
    String imagePath,
    String filePrefix,
  ) async {
    try {
      // First, crop the image to square aspect ratio
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: imagePath,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Wound Photo',
            toolbarColor: Colors.blue.shade600,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
            hideBottomControls: false,
            showCropGrid: true,
          ),
          IOSUiSettings(
            minimumAspectRatio: 1.0,
            aspectRatioLockEnabled: true,
            title: 'Crop Wound Photo',
          ),
        ],
      );

      if (croppedFile == null) return null;

      // Read the cropped image
      final bytes = await File(croppedFile.path).readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) {
        throw Exception('Failed to decode image');
      }

      // Resize to exactly 224x224 pixels
      final resized = img.copyResize(image, width: 224, height: 224);

      // Save the processed image
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${filePrefix}_${timestamp}_224x224.jpg';
      final savedPath = '${directory.path}/$fileName';

      final savedFile = File(savedPath);
      await savedFile.writeAsBytes(img.encodeJpg(resized, quality: 90));

      Get.snackbar(
        'Success',
        'Photo processed and resized to 224x224 pixels',
        snackPosition: SnackPosition.BOTTOM,
      );

      return savedPath;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to process image: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }
  }
}
