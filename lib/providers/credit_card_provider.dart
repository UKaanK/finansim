import 'package:flutter/material.dart';
import 'package:finansim/models/credit_card.dart';
import 'package:finansim/services/hive_service.dart';

class CreditCardProvider with ChangeNotifier {
  final HiveService _hiveService;
  List<CreditCard> _creditCards = [];
  bool _isLoading = false;

  CreditCardProvider(this._hiveService);

  List<CreditCard> get creditCards => _creditCards;
  bool get isLoading => _isLoading;

  Future<void> fetchCreditCards() async {
    _setLoading(true);
    _creditCards = _hiveService.getCreditCards();
    _setLoading(false);
    // notifyListeners build dışında çağrıldığı için addPostFrameCallback'e gerek yok,
    // ancak yine de eklemek daha güvenli olabilir. Şimdilik direkt çağıralım.
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   if (hasListeners) notifyListeners();
    // });
    // notifyListeners(); // setLoading içinde zaten çağrılıyor.
  }

  Future<void> addCreditCard({
    required String cardName,
    required String statementDate,
    required String dueDate,
  }) async {
    _setLoading(true); // Başlat
    await _hiveService.addCreditCard(
      cardName: cardName,
      statementDate: statementDate,
      dueDate: dueDate,
    );
    await fetchCreditCards(); // Listeyi yenile (bu setLoading(false) ve notifyListeners içerir)
  }

  Future<void> clearCreditCards() async {
    _setLoading(true); // Başlat
    await _hiveService.clearCreditCards();
    await fetchCreditCards(); // Listeyi yenile
  }
    
  Future<void> deleteCreditCard(dynamic key) async {
    _setLoading(true); // Başlat
    await _hiveService.deleteCreditCard(key);
    await fetchCreditCards(); // Listeyi yenile
  }

  // Yükleme durumunu ayarlayan ve dinleyicileri bilgilendiren özel metod
  void _setLoading(bool value) {
    _isLoading = value;
     // Build işlemi sırasında çağrılmaması için kontrol ekleyelim
    WidgetsBinding.instance.addPostFrameCallback((_) {
       if (hasListeners) notifyListeners();
    });
  }
}
