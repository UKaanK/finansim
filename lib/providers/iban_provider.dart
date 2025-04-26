import 'package:flutter/material.dart'; // Flutter material import'unu ekleyin
import 'package:finansim/models/iban.dart';
import 'package:finansim/services/hive_service.dart';

class IBANProvider with ChangeNotifier {
  final HiveService hiveService;
  List<IBAN> _ibans = [];
  bool _isLoading = false; // Yükleme durumu ekleyelim

  IBANProvider(this.hiveService);

  List<IBAN> get ibans => _ibans;
  bool get isLoading => _isLoading; // Yükleme durumu için getter

  Future<void> fetchIBANs() async {
    _isLoading = true;
    // Hemen notifyListeners çağırarak yükleme durumunu bildirelim (build dışında olduğu için güvenli)
    WidgetsBinding.instance.addPostFrameCallback((_) {
       if (hasListeners) notifyListeners();
    });


    _ibans = hiveService.getIBANs(); // Veriyi al
    _isLoading = false; // Yükleme bitti

    // Frame tamamlandıktan sonra dinleyicileri bilgilendir
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (hasListeners) { // Provider hala mount edilmiş mi kontrol et
           notifyListeners();
      }
    });
  }

  Future<void> addIBAN(String title, String ibanNumber) async {
    await hiveService.addIBAN(title, ibanNumber);
    await fetchIBANs(); // Veri eklendikten sonra listeyi yenile (bu da notifyListeners'ı çağıracak)
  }

  Future<void> clearIBANs() async {
    await hiveService.clearIBANs();
    await fetchIBANs(); // Veri temizlendikten sonra listeyi yenile (bu da notifyListeners'ı çağıracak)
  }
}