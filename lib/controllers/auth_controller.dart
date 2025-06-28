import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../screens/main_layout.dart';
import '../screens/login_screen.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();
  final GetStorage _storage = GetStorage();

  // Observable variables
  Rx<User?> currentUser = Rx<User?>(null);
  RxBool isLoading = false.obs;
  RxBool isLoggedIn = false.obs;
  RxString errorMessage = ''.obs;

  // Token key for storage
  final String _tokenKey = 'auth_token';

  @override
  void onInit() {
    super.onInit();
    _checkAuthStatus();
  }

  // Check if user is already logged in
  void _checkAuthStatus() async {
    try {
      final token = _storage.read(_tokenKey);
      if (token != null) {
        isLoading(true);
        final user = await _authService.getCurrentUser(token);
        currentUser.value = user;
        isLoggedIn(true);
      }
    } catch (e) {
      // Token is invalid, remove it
      _storage.remove(_tokenKey);
    } finally {
      isLoading(false);
    }
  }

  // Login method
  Future<void> login(String email, String password) async {
    try {
      isLoading(true);
      errorMessage('');

      final user = await _authService.login(email, password);

      // Store token
      if (user.token != null) {
        await _storage.write(_tokenKey, user.token);
      }

      currentUser.value = user;
      isLoggedIn(true);

      // Navigate to main screen
      Get.offAll(() => const MainLayout());

      Get.snackbar(
        'Success',
        'Welcome back, ${user.name}!',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      errorMessage(_cleanErrorMessage(e.toString()));
      Get.snackbar(
        'Login Failed',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading(false);
    }
  }

  // Logout method
  Future<void> logout() async {
    try {
      isLoading(true);

      await _authService.logout();

      // Clear stored data
      await _storage.remove(_tokenKey);
      currentUser.value = null;
      isLoggedIn(false);

      // Navigate to login screen
      Get.offAll(() => const LoginScreen());

      Get.snackbar(
        'Logged Out',
        'You have been logged out successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Logout failed: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading(false);
    }
  }

  // Update profile picture
  Future<void> updateProfilePicture(String imagePath) async {
    try {
      final user = currentUser.value;
      if (user?.token == null) {
        throw Exception('User not authenticated');
      }

      isLoading(true);
      errorMessage('');

      final updatedUser = await _authService.updateProfilePicture(
        user!.token!,
        imagePath,
      );

      currentUser.value = updatedUser;

      Get.snackbar(
        'Success',
        'Profile picture updated successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      errorMessage(_cleanErrorMessage(e.toString()));
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading(false);
    }
  }

  // Change password
  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      final user = currentUser.value;
      if (user?.token == null) {
        throw Exception('User not authenticated');
      }

      isLoading(true);
      errorMessage('');

      await _authService.changePassword(
        user!.token!,
        currentPassword,
        newPassword,
      );

      Get.snackbar(
        'Success',
        'Password changed successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      errorMessage(_cleanErrorMessage(e.toString()));
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading(false);
    }
  }

  // Helper method to clean error messages
  String _cleanErrorMessage(String error) {
    return error.replaceAll('Exception: ', '');
  }
}
