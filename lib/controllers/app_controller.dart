import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class AppController extends GetxController {
  final GetStorage _storage = GetStorage();

  // Observable variables
  RxInt currentIndex = 0.obs;
  RxString selectedCompany = ''.obs;

  // Mock companies list
  final List<String> companies = [
    'Acme Corporation',
    'TechFlow Solutions',
    'Global Industries',
    'InnovateCorp',
    'NextGen Systems',
    'Digital Dynamics',
  ];

  // Storage key for selected company
  final String _companyKey = 'selected_company';

  @override
  void onInit() {
    super.onInit();
    _loadSelectedCompany();
  }

  // Load previously selected company
  void _loadSelectedCompany() {
    final savedCompany = _storage.read(_companyKey);
    if (savedCompany != null && companies.contains(savedCompany)) {
      selectedCompany.value = savedCompany;
    } else if (companies.isNotEmpty) {
      selectedCompany.value = companies.first;
    }
  }

  // Change selected company
  void selectCompany(String company) {
    selectedCompany.value = company;
    _storage.write(_companyKey, company);
  }

  // Change bottom navigation index
  void changeIndex(int index) {
    currentIndex.value = index;
  }

  // Get company display name (shortened if too long)
  String get displayCompanyName {
    if (selectedCompany.value.isEmpty) return 'Select Company';
    if (selectedCompany.value.length > 15) {
      return '${selectedCompany.value.substring(0, 12)}...';
    }
    return selectedCompany.value;
  }
}
