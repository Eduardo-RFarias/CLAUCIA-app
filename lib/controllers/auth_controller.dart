import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../models/professional_model.dart';
import '../services/auth_service.dart';
import '../screens/main_layout.dart';
import '../screens/login_screen.dart';
import '../services/localization_service.dart';
import 'dart:io';
import 'dart:convert';

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
    // Token is already saved in storage and ApiClient adds it automatically in requests.
    // We still need the Professional profile. For simplicity, require user to login again if app restarts.
  }

  Future<void> login(String coren, String password) async {
    try {
      isLoading.value = true;
      final professional = await _authService.login(coren, password);
      currentUser.value = professional;
      isLoggedIn.value = true;
      if (professional.token != null) {
        await _storage.write(_tokenKey, professional.token);
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
    currentUser.value = null;
    isLoggedIn.value = false;
    Get.offAll(() => const LoginScreen());
  }

  Future<void> updateProfilePhoto(String imagePath) async {
    final prof = currentUser.value;
    if (prof == null) return;
    try {
      isLoading.value = true;
      String b64 = '';
      if (imagePath.isNotEmpty) {
        final bytes = await File(imagePath).readAsBytes();
        b64 = base64Encode(bytes);
      }
      final updated = await _authService.updatePhoto(prof.coren, b64);
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
