import 'dart:io';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import '../models/sample_model.dart';
import '../utils/logger.dart';

class WoundClassifierService {
  static WoundClassifierService? _instance;
  Interpreter? _interpreter;

  // Private constructor for singleton pattern
  WoundClassifierService._();

  // Singleton instance getter
  static Future<WoundClassifierService> getInstance() async {
    if (_instance == null) {
      _instance = WoundClassifierService._();
      await _instance!._loadModel();
    }
    return _instance!;
  }

  // Load the TFLite model
  Future<void> _loadModel() async {
    try {
      final modelPath = 'assets/models/mobilenet_v3_224.tflite';

      // Configure interpreter options with delegates for better performance
      final options = InterpreterOptions();

      // Use appropriate delegates based on platform
      if (Platform.isAndroid) {
        // Use XNNPACK Delegate for better CPU performance on Android
        options.addDelegate(XNNPackDelegate());

        // Uncomment to use GPU on real devices (not emulator)
        // options.addDelegate(GpuDelegateV2());
      }

      if (Platform.isIOS) {
        // Use Metal GPU delegate on iOS
        options.addDelegate(GpuDelegate());
      }

      _interpreter = await Interpreter.fromAsset(modelPath, options: options);

      // Log tensor shapes for verification
      final inputShape = _interpreter!.getInputTensor(0).shape;
      final outputShape = _interpreter!.getOutputTensor(0).shape;
      AppLogger.i('Model loaded - input: $inputShape, output: $outputShape');
    } catch (e) {
      AppLogger.e('Error loading model:', e);
      rethrow;
    }
  }

  // Preprocess the image to match model input requirements
  List<List<List<List<double>>>> _preprocessImage(File imageFile) {
    // Read image bytes
    final bytes = imageFile.readAsBytesSync();

    // Decode image
    img.Image? image = img.decodeImage(bytes);
    if (image == null) throw Exception('Failed to decode image');

    // Resize to 224x224 if not already (should be done already by ImageProcessor,
    // but we ensure it here for safety)
    if (image.width != 224 || image.height != 224) {
      image = img.copyResize(image, width: 224, height: 224);
    }

    // Create a buffer for the normalized pixel values
    // Shape: 1 (batch) x 224 (height) x 224 (width) x 3 (RGB channels)
    var inputBuffer = List.generate(
      1,
      (_) => List.generate(
        224,
        (_) => List.generate(224, (_) => List.generate(3, (_) => 0.0)),
      ),
    );

    // Normalize pixel values from [0, 255] to [-1, 1]
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);

        // Extract RGB values (not ARGB, as per requirement)
        final r = pixel.r.toDouble();
        final g = pixel.g.toDouble();
        final b = pixel.b.toDouble();

        // Use raw pixel values (0-255) as the model expects
        inputBuffer[0][y][x][0] = r;
        inputBuffer[0][y][x][1] = g;
        inputBuffer[0][y][x][2] = b;
      }
    }

    return inputBuffer;
  }

  // Classify the wound image
  Future<int> classifyWound(File imageFile) async {
    if (_interpreter == null) {
      await _loadModel();
      if (_interpreter == null) {
        throw Exception('Interpreter is not initialized');
      }
    }

    try {
      // Preprocess the image
      final input = _preprocessImage(imageFile);

      // Create output buffer for the 7 classes
      int numClasses = 7; // Classes 0-6
      var outputBuffer = List.filled(
        1 * numClasses,
        0.0,
      ).reshape([1, numClasses]);

      // Run inference
      _interpreter!.run(input, outputBuffer);

      // Get the class with highest probability
      List<double> probabilities = List<double>.from(outputBuffer[0]);
      int classIndex = 0;
      double maxProb = probabilities[0];

      for (int i = 0; i < probabilities.length; i++) {
        if (probabilities[i] > maxProb) {
          maxProb = probabilities[i];
          classIndex = i;
        }
      }

      AppLogger.i(
        'Classification result: $classIndex (confidence: ${maxProb.toStringAsFixed(4)})',
      );
      return classIndex;
    } catch (e) {
      AppLogger.e('Error during classification:', e);
      return WagnerClassification.normalSkin.grade;
    }
  }

  // Clean up resources
  void dispose() {
    _interpreter?.close();
    _interpreter = null;
  }
}
