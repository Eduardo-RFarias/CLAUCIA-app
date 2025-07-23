import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../controllers/auth_controller.dart';
import '../services/localization_service.dart';
import 'change_password_dialog.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final ImagePicker imagePicker = ImagePicker();

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.profile),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutDialog(context, authController),
            tooltip: context.l10n.logout,
          ),
        ],
      ),
      body: Obx(() {
        final user = authController.currentUser.value;
        if (user == null) {
          return Center(child: Text(context.l10n.noUserDataAvailable));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Header
              _buildProfileHeader(
                context,
                authController,
                imagePicker,
                user.name,
                user.coren,
                user.photo,
              ),
              const SizedBox(height: 32),

              // User Information Section
              _buildSectionTitle(
                context.l10n.userInformation,
              ), // This string is not in ARB files
              const SizedBox(height: 16),
              _buildInfoCard([
                _buildInfoTile(
                  icon: Icons.person,
                  title: context.l10n.fullName,
                  subtitle: user.name,
                ),
                _buildInfoTile(
                  icon: Icons.badge,
                  title: 'COREN',
                  subtitle: user.coren,
                ),
                _buildInfoTile(
                  icon: Icons.verified_user,
                  title: context.l10n.accountStatus,
                  subtitle: context.l10n.active,
                  subtitleColor: Colors.green,
                ),
              ]),
              const SizedBox(height: 32),

              // Settings Section
              _buildSectionTitle(context.l10n.settings),
              const SizedBox(height: 16),
              _buildSettingsCard([
                _buildSettingsTile(
                  icon: Icons.security,
                  title: context.l10n.security,
                  subtitle: context.l10n.passwordAndSecuritySettings,
                  onTap: () => _showChangePasswordDialog(context),
                ),
                _buildSettingsTile(
                  icon: Icons.language,
                  title: context.l10n.language,
                  subtitle: _getCurrentLanguageName(context),
                  onTap: () => _showLanguageSelectionDialog(context),
                ),
              ]),
              const SizedBox(height: 32),

              // Version Information
              _buildSectionTitle(context.l10n.version),
              const SizedBox(height: 16),
              _buildVersionCard(context),
              const SizedBox(height: 32),

              // Logout Button
              _buildLogoutButton(context, authController),
              const SizedBox(height: 16),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildProfileHeader(
    BuildContext context,
    AuthController authController,
    ImagePicker imagePicker,
    String name,
    String email,
    String? profilePicture,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue.shade400, Colors.blue.shade600],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              _buildProfileAvatar(profilePicture, name),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap:
                      () => _showImagePickerOptions(
                        context,
                        authController,
                        imagePicker,
                      ),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade600,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            email,
            style: const TextStyle(fontSize: 16, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  /// Returns an [ImageProvider] for a local file path **or** a Base-64 image.
  ///
  /// 1. If [src] can be decoded from Base-64 (raw string or data URI) it uses
  ///    [MemoryImage].
  /// 2. Otherwise it falls back to loading a file from disk with [FileImage].
  ImageProvider? _localImageProvider(String src) {
    // Handle optional data URI prefix like "data:image/png;base64,XXX"
    final base64Part =
        src.startsWith('data:image/') ? src.split(',').last : src;

    try {
      final bytes = base64Decode(base64Part);
      return MemoryImage(bytes);
    } catch (_) {
      // Not valid Base-64 => treat as file path
      return null;
    }
  }

  /// Build profile avatar with proper error handling for network images
  Widget _buildProfileAvatar(String? profilePicture, String name) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white),
      child: ClipOval(
        child:
            (profilePicture != null && profilePicture.isNotEmpty)
                ? (profilePicture.startsWith('http')
                    ? CachedNetworkImage(
                      imageUrl: profilePicture,
                      fit: BoxFit.cover,
                      placeholder:
                          (context, url) => Container(
                            color: Colors.white,
                            child: Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.blue.shade600,
                                ),
                              ),
                            ),
                          ),
                      errorWidget:
                          (context, url, error) => _buildInitialsAvatar(name),
                    )
                    : _buildLocalImageAvatar(profilePicture, name))
                : _buildInitialsAvatar(name),
      ),
    );
  }

  /// Build avatar with initials fallback
  Widget _buildInitialsAvatar(String name) {
    return Container(
      color: Colors.white,
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : 'U',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade600,
          ),
        ),
      ),
    );
  }

  /// Build avatar from local image with error handling
  Widget _buildLocalImageAvatar(String imagePath, String name) {
    final imageProvider = _localImageProvider(imagePath);
    if (imageProvider != null) {
      return Image(
        image: imageProvider,
        fit: BoxFit.cover,
        errorBuilder:
            (context, error, stackTrace) => _buildInitialsAvatar(name),
      );
    } else {
      return _buildInitialsAvatar(name);
    }
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Color? subtitleColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.blue.shade600, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: subtitleColor ?? Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(children: children),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.grey.shade700, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildVersionCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _buildInfoChip(context.l10n.version, '1.0.0'),
            const SizedBox(width: 8),
            _buildInfoChip(context.l10n.build, '1'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          fontSize: 12,
          color: Colors.blue.shade700,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildLogoutButton(
    BuildContext context,
    AuthController authController,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _showLogoutDialog(context, authController),
        icon: const Icon(Icons.logout),
        label: Text(context.l10n.signOut),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthController authController) {
    Get.dialog(
      AlertDialog(
        title: Text(context.l10n.signOut),
        content: Text(context.l10n.areYouSureSignOut),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(context.l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              authController.logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(context.l10n.signOut),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    Get.dialog(const ChangePasswordDialog());
  }

  void _showImagePickerOptions(
    BuildContext context,
    AuthController authController,
    ImagePicker imagePicker,
  ) {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text(context.l10n.chooseFromGallery),
                onTap: () {
                  Get.back();
                  _pickImage(
                    context,
                    ImageSource.gallery,
                    authController,
                    imagePicker,
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: Text(context.l10n.takeAPhoto),
                onTap: () {
                  Get.back();
                  _pickImage(
                    context,
                    ImageSource.camera,
                    authController,
                    imagePicker,
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: Text(context.l10n.removePhoto),
                onTap: () {
                  Get.back();
                  _removeProfilePicture(authController);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _pickImage(
    BuildContext context,
    ImageSource source,
    AuthController authController,
    ImagePicker imagePicker,
  ) async {
    // Extract localized strings before async gap
    final errorTitle = context.l10n.error;
    final errorMessage = context.l10n.failedToPickImage;

    try {
      final XFile? pickedFile = await imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        authController.updateProfilePhoto(pickedFile.path);
      }
    } catch (e) {
      Get.snackbar(
        errorTitle,
        '$errorMessage: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _removeProfilePicture(AuthController authController) {
    authController.updateProfilePhoto('');
  }

  String _getCurrentLanguageName(BuildContext context) {
    final LocalizationService localizationService =
        Get.find<LocalizationService>();
    return localizationService.getLanguageName(
      localizationService.currentLocale.value,
    );
  }

  void _showLanguageSelectionDialog(BuildContext context) {
    final LocalizationService localizationService =
        Get.find<LocalizationService>();

    Get.dialog(
      AlertDialog(
        title: Text(context.l10n.selectLanguage),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children:
              LocalizationService.supportedLocales.map((locale) {
                final isSelected = localizationService.isCurrentLocale(locale);
                return ListTile(
                  leading: Text(
                    localizationService.getLanguageFlag(locale),
                    style: const TextStyle(fontSize: 24),
                  ),
                  title: Text(localizationService.getLanguageName(locale)),
                  trailing:
                      isSelected
                          ? const Icon(Icons.check, color: Colors.blue)
                          : null,
                  onTap: () {
                    localizationService.changeLanguage(locale);
                    Get.back();
                  },
                );
              }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(context.l10n.cancel),
          ),
        ],
      ),
    );
  }
}
