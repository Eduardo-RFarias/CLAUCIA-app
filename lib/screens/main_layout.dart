import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/app_controller.dart';
import '../services/localization_service.dart';
import 'home_screen.dart';
import 'profile_screen.dart';

class MainLayout extends StatelessWidget {
  const MainLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final AppController appController = Get.put(AppController());

    return Scaffold(
      body: Obx(() {
        switch (appController.currentIndex.value) {
          case 0:
            return const HomeScreen();
          case 1:
            return const ProfileScreen();
          default:
            return const HomeScreen();
        }
      }),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.3),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomAppBar(
          height: 90,
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Home Button
                Obx(
                  () => _buildNavButton(
                    context: context,
                    icon: Icons.home,
                    label: context.l10n.home,
                    isSelected: appController.currentIndex.value == 0,
                    onTap: () => appController.changeIndex(0),
                  ),
                ),

                // Company Selector
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildCompanySelector(context, appController),
                  ),
                ),

                // Profile Button
                Obx(
                  () => _buildNavButton(
                    context: context,
                    icon: Icons.person,
                    label: context.l10n.profile,
                    isSelected: appController.currentIndex.value == 1,
                    onTap: () => appController.changeIndex(1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade50 : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.blue.shade600 : Colors.grey.shade600,
              size: 22,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.blue.shade600 : Colors.grey.shade600,
                fontSize: 8,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                height: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompanySelector(
    BuildContext context,
    AppController appController,
  ) {
    return Obx(
      () => GestureDetector(
        onTap: () => _showCompanySelection(context, appController),
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.business, color: Colors.grey.shade700, size: 16),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  appController.displayCompanyName,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.arrow_drop_down,
                color: Colors.grey.shade700,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCompanySelection(
    BuildContext context,
    AppController appController,
  ) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.business, color: Colors.blue.shade600),
                const SizedBox(width: 8),
                Text(
                  context.l10n.selectCompany,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...appController.companies.map(
              (company) => Obx(
                () => ListTile(
                  leading: Icon(
                    Icons.business_center,
                    color:
                        appController.selectedCompany.value == company
                            ? Colors.blue.shade600
                            : Colors.grey.shade600,
                  ),
                  title: Text(
                    company,
                    style: TextStyle(
                      fontWeight:
                          appController.selectedCompany.value == company
                              ? FontWeight.w600
                              : FontWeight.normal,
                      color:
                          appController.selectedCompany.value == company
                              ? Colors.blue.shade600
                              : Colors.black87,
                    ),
                  ),
                  trailing:
                      appController.selectedCompany.value == company
                          ? Icon(Icons.check, color: Colors.blue.shade600)
                          : null,
                  onTap: () {
                    appController.selectCompany(company);
                    Get.back();
                    Get.snackbar(
                      context.l10n.companySelected,
                      '${context.l10n.nowWorkingWith} $company',
                      snackPosition: SnackPosition.BOTTOM,
                      duration: const Duration(seconds: 2),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
