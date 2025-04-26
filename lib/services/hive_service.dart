import 'package:hive/hive.dart';
import 'package:finansim/models/iban.dart';
import 'package:finansim/models/credit_card.dart'; // CreditCard modelini import et
import 'package:encrypt/encrypt.dart';

class HiveService {
  final Box<IBAN> _ibanBox; // IBAN kutusu
  final Box<CreditCard> _creditCardBox; // Kredi Kartı kutusu

  // Şifreleme anahtarı ve IV (ortak kullanılabilir)
  final _key = Key.fromUtf8('1234567890123456'); 
  final _iv = IV.fromLength(16); 

  // Constructor'ı iki kutuyu da alacak şekilde güncelle
  HiveService({required Box<IBAN> ibanBox, required Box<CreditCard> creditCardBox}) 
    : _ibanBox = ibanBox,
      _creditCardBox = creditCardBox;

  // Şifreleyiciyi oluşturmak için yardımcı metod
  Encrypter _getEncrypter() {
    return Encrypter(AES(_key));
  }

  // --- IBAN Metodları ---
  Future<void> addIBAN(String title, String ibanNumber) async {
    final encrypter = _getEncrypter();
    final encryptedTitle = encrypter.encrypt(title, iv: _iv);
    final encryptedIbanNumber = encrypter.encrypt(ibanNumber, iv: _iv);
    await _ibanBox.add(IBAN(title: encryptedTitle.base64, ibanNumber: encryptedIbanNumber.base64));
  }

  List<IBAN> getIBANs() {
    final encrypter = _getEncrypter();
    // print('DEBUG: HiveService.getIBANs() içindeki _box.values: ${_ibanBox.values.toList()}'); 
    final encryptedList = _ibanBox.values.toList(); 
    final decryptedList = <IBAN>[]; 

    for (var encryptedIBAN in encryptedList) {
      try {
        final decryptedTitle = encrypter.decrypt64(encryptedIBAN.title, iv: _iv);
        final decryptedIbanNumber = encrypter.decrypt64(encryptedIBAN.ibanNumber, iv: _iv);
        decryptedList.add(IBAN(title: decryptedTitle, ibanNumber: decryptedIbanNumber));
       // print("Şifrelenmiş IBAN: ${encryptedIBAN.ibanNumber} ve Title:${encryptedIBAN.title}");
      } catch (e) {
        print("IBAN Şifre çözme hatası: $e - IBAN: ${encryptedIBAN.title}");
      }
    }
    return decryptedList; 
  }

  Future<void> clearIBANs() async {
    await _ibanBox.clear();
  }

  // --- Kredi Kartı Metodları ---

  Future<void> addCreditCard({
    required String cardName, 
    required String statementDate, 
    required String dueDate
  }) async {
    final encrypter = _getEncrypter();
    
    // Verileri şifrele
    final encryptedCardName = encrypter.encrypt(cardName, iv: _iv).base64;
    final encryptedStatementDate = encrypter.encrypt(statementDate, iv: _iv).base64;
    final encryptedDueDate = encrypter.encrypt(dueDate, iv: _iv).base64;

    // Şifrelenmiş verilerle CreditCard nesnesi oluştur ve kutuya ekle
    final newCard = CreditCard.encrypted(
      encryptedCardName: encryptedCardName,
      encryptedStatementDate: encryptedStatementDate,
      encryptedDueDate: encryptedDueDate,
    );
    await _creditCardBox.add(newCard);
  }

  List<CreditCard> getCreditCards() {
    final encrypter = _getEncrypter();
    final encryptedList = _creditCardBox.values.toList(); 
    final decryptedList = <CreditCard>[]; 

    for (var encryptedCard in encryptedList) {
      try {
        // Şifreli alanları çöz
        final decryptedCardName = encrypter.decrypt64(encryptedCard.encryptedCardName, iv: _iv);
        final decryptedStatementDate = encrypter.decrypt64(encryptedCard.encryptedStatementDate, iv: _iv);
        final decryptedDueDate = encrypter.decrypt64(encryptedCard.encryptedDueDate, iv: _iv);
        
        // Çözülmüş verilerle yeni bir nesne oluştur (veya mevcut nesneyi güncelle)
        final decryptedCard = CreditCard.decrypted(
          cardName: decryptedCardName,
          statementDate: decryptedStatementDate,
          dueDate: decryptedDueDate,
        );
        // HiveObject'tan türediği için anahtarını koruyalım (silme/güncelleme için önemli olabilir)
        
        decryptedList.add(decryptedCard);
      } catch (e) {
        print("Kredi Kartı Şifre çözme hatası: $e - Kart Adı (Şifreli): ${encryptedCard.encryptedCardName}");
      }
    }
    return decryptedList; 
  }

  Future<void> clearCreditCards() async {
    await _creditCardBox.clear();
  }

   // Belirli bir kredi kartını silmek için (anahtar kullanarak)
  Future<void> deleteCreditCard(dynamic key) async {
    await _creditCardBox.delete(key);
  }
}