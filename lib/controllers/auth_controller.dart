import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../models/professional_model.dart';
import '../services/auth_service.dart';
import '../screens/main_layout.dart';
import '../screens/login_screen.dart';
import '../services/localization_service.dart';
import '../utils/image_utils.dart';
import '../utils/logger.dart';
import 'dart:io';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();
  final GetStorage _storage = GetStorage();

  // Observable state
  final Rx<Professional?> currentUser = Rx<Professional?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isLoggedIn = false.obs;
  final RxString errorMessage = ''.obs;

  static const String _tokenKey = 'auth_token';

  @override
  void onInit() {
    super.onInit();
    _restoreSession();
  }

  void _restoreSession() async {
    final token = _storage.read<String>(_tokenKey);
    if (token == null) return; // not logged in

    // Try to use existing token
    try {
      _authService.setToken(token);
      // Try to fetch some user data to validate the token
      await _restoreUserProfile(token);
    } catch (e) {
      // Token is invalid/expired, clear it
      await _storage.remove(_tokenKey);
      await _storage.remove('user_coren'); // Also clear stored COREN
      _authService.clearAllTokens();
      isLoggedIn.value = false;
    }
  }

  /// Restores user profile from stored token
  Future<void> _restoreUserProfile(String token) async {
    // We need to get the identifier somehow - let's try a different approach
    // For now, we'll store the COREN alongside the token or get it from token
    final storedCoren = _storage.read<String>('user_coren');
    if (storedCoren != null) {
      final professional = await _authService.fetchProfessionalProfile(
        storedCoren,
        token,
      );
      currentUser.value = professional;
      isLoggedIn.value = true;
    } else {
      throw Exception('No stored user identifier');
    }
  }

  Future<void> login(String coren, String password) async {
    try {
      isLoading.value = true;
      final professional = await _authService.login(coren, password);
      currentUser.value = professional;
      isLoggedIn.value = true;
      if (professional.token != null) {
        await _storage.write(_tokenKey, professional.token);
        await _storage.write(
          'user_coren',
          coren,
        ); // Store COREN for session restoration
      }
      Get.offAll(() => const MainLayout());
      Get.snackbar(
        l10n.success,
        l10n.welcomeBackUser(professional.name),
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      errorMessage.value = _clean(e.toString());
      Get.snackbar(
        l10n.loginFailed,
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    await _storage.remove(_tokenKey);
    await _storage.remove('user_coren'); // Also clear stored COREN
    currentUser.value = null;
    isLoggedIn.value = false;
    Get.offAll(() => const LoginScreen());
  }

  Future<void> updateProfilePhoto(String photoSource) async {
    final prof = currentUser.value;
    if (prof == null) return;
    try {
      isLoading.value = true;

      // If photoSource is empty, send an empty string to remove the photo
      String dataUri = '';

      // If photoSource is already a data URI, use it as is
      if (photoSource.startsWith('data:image/')) {
        dataUri = photoSource;
      }
      // If it's a file path, convert it to a data URI
      else if (photoSource.isNotEmpty) {
        try {
          final file = File(photoSource);
          if (await file.exists()) {
            dataUri = await ImageUtils.fileToDataUri(file);
          }
        } catch (e) {
          // If there's an error, log it and continue with empty string
          AppLogger.i('Error processing image file: $e');
        }
      }

      final updated = await _authService.updatePhoto(prof.coren, dataUri);
      currentUser.value = updated.copyWith(token: prof.token);
    } catch (e) {
      Get.snackbar(
        l10n.error,
        _clean(e.toString()),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> changePassword(String newPassword) async {
    final prof = currentUser.value;
    if (prof == null) return;
    try {
      isLoading.value = true;
      await _authService.changePassword(prof.coren, newPassword);
      Get.snackbar(
        l10n.success,
        l10n.passwordChangedSuccessfully,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        l10n.error,
        _clean(e.toString()),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  String _clean(String e) => e.replaceAll('Exception: ', '');
}
