import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'controllers/auth_controller.dart';
import 'screens/login_screen.dart';
import 'screens/main_layout.dart';
import 'services/localization_service.dart';
import 'services/wound_classifier_service.dart';
import 'utils/logger.dart';

// Generated localization files
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  // Initialize LocalizationService
  Get.put(LocalizationService());

  // Preload the TFLite model in background
  _preloadTFLiteModel();

  runApp(const MyApp());
}

// Preload the TFLite model to avoid delay during first classification
Future<void> _preloadTFLiteModel() async {
  try {
    // Initialize the classifier service in the background
    await WoundClassifierService.getInstance();
    AppLogger.i('TFLite model preloaded successfully');
  } catch (e) {
    AppLogger.e('Error preloading TFLite model:', e);
    // Continue with app initialization even if model fails to load
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final LocalizationService localizationService =
        Get.find<LocalizationService>();

    return Obx(
      () => GetMaterialApp(
        title: 'Claucia App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
          appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
        ),
        // Internationalization configuration
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: localizationService.currentLocale.value,
        fallbackLocale:
            LocalizationService.defaultLocale, // Now defaults to Portuguese
        home: const AuthWrapper(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.put(AuthController());

    return Obx(() {
      if (authController.isLoading.value) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }

      return authController.isLoggedIn.value
          ? const MainLayout()
          : const LoginScreen();
    });
  }
}
