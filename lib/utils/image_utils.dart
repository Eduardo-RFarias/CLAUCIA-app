import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

class ImageUtils {
  static const String _cdnBaseUrl = String.fromEnvironment(
    'CDN_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000',
  );

  /// Converts an image file to the required data URI format for API uploads
  static Future<String> fileToDataUri(File file) async {
    final bytes = await file.readAsBytes();
    final base64Data = base64Encode(bytes);

    // Determine mime type based on file extension
    String mimeType = 'image/jpeg'; // Default
    final extension = file.path.split('.').last.toLowerCase();

    if (extension == 'png') {
      mimeType = 'image/png';
    } else if (extension == 'gif') {
      mimeType = 'image/gif';
    } else if (extension == 'webp') {
      mimeType = 'image/webp';
    }

    return 'data:$mimeType;base64,$base64Data';
  }

  /// Converts a relative path to a full CDN URL for static assets
  static String pathToUrl(String? path) {
    if (path == null || path.isEmpty) {
      return '';
    }

    // If it's already a full URL or data URI, return as is
    if (path.startsWith('http') || path.startsWith('data:')) {
      return path;
    }

    // Ensure path starts with '/'
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    // Use CDN base URL for static assets
    return '$_cdnBaseUrl$normalizedPath';
  }

  /// Returns an appropriate ImageProvider based on the image source
  static ImageProvider getImageProvider(String? src) {
    if (src == null || src.isEmpty) {
      throw Exception('Empty image source');
    }

    // Handle data URIs
    if (src.startsWith('data:image/')) {
      try {
        final base64Data = src.split(',').last;
        final bytes = base64Decode(base64Data);
        return MemoryImage(bytes);
      } catch (e) {
        throw Exception('Invalid data URI format: $e');
      }
    }

    // Handle HTTP URLs
    if (src.startsWith('http')) {
      return NetworkImage(src);
    }

    // Handle local file paths
    try {
      final file = File(src);
      if (file.existsSync()) {
        return FileImage(file);
      }
    } catch (_) {
      // Fall through to convert relative path to URL
    }

    // Assume it's a relative path from the CDN
    return NetworkImage(pathToUrl(src));
  }
}
