import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../services/localization_service.dart';
import '../services/institution_service.dart';
import '../models/institution_model.dart';
import '../controllers/auth_controller.dart';

class AppController extends GetxController {
  final GetStorage _storage = GetStorage();
  final InstitutionService _institutionService = InstitutionService();
  final AuthController _authController = Get.find<AuthController>();

  final RxInt currentIndex = 0.obs;
  final RxString selectedInstitution = ''.obs;
  final RxList<Institution> institutions = <Institution>[].obs;
  final String _institutionKey = 'selected_institution';

  @override
  void onInit() {
    super.onInit();
    _loadInstitutions();
  }

  Future<void> _loadInstitutions() async {
    try {
      List<Institution> list = [];
      final professional = _authController.currentUser.value;
      if (professional != null) {
        list = await _institutionService.getInstitutionsForProfessional(
          professional.coren,
        );
      }
      if (list.isEmpty) {
        // fallback to all institutions (admin use?)
        list = await _institutionService.getAllInstitutions();
      }
      institutions.assignAll(list);

      final saved = _storage.read<String>(_institutionKey);
      if (saved != null && list.any((i) => i.name == saved)) {
        selectedInstitution.value = saved;
      } else if (list.isNotEmpty) {
        selectedInstitution.value = list.first.name;
      }
    } catch (_) {
      // keep empty list; UI can handle error message elsewhere
    }
  }

  void selectInstitution(String name) {
    selectedInstitution.value = name;
    _storage.write(_institutionKey, name);
  }

  void changeIndex(int idx) => currentIndex.value = idx;

  String get displayInstitutionName {
    final name = selectedInstitution.value;
    if (name.isEmpty) return l10n.selectCompany; // reuse localization key
    return name.length > 15 ? '${name.substring(0, 12)}...' : name;
  }
}
