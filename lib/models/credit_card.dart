import 'package:hive/hive.dart';

part 'credit_card.g.dart'; // Hive generator için gerekli

@HiveType(typeId: 1) // IBAN için 0 kullanmıştık, bunun için 1 kullanalım
class CreditCard extends HiveObject { // HiveObject'tan türetmek anahtar bazlı erişimi kolaylaştırır

  @HiveField(0)
  late String cardName; // Şifrelenecek (örneğin, "Banka X Gold")

  @HiveField(1)
  late String statementDate; // Şifrelenecek (örneğin, "Her ayın 15'i" veya belirli bir gün int?) Belki int olarak gün saklamak daha iyi? Şimdilik String bırakalım.

  @HiveField(2)
  late String dueDate; // Şifrelenecek (örneğin, "Ekstreden 10 gün sonra" veya belirli bir gün int?) Belki int olarak gün saklamak daha iyi? Şimdilik String bırakalım.

  @HiveField(3)
  late String encryptedCardName; // Gerçek şifreli veri

  @HiveField(4)
  late String encryptedStatementDate; // Gerçek şifreli veri

  @HiveField(5)
  late String encryptedDueDate; // Gerçek şifreli veri

  // Hive'ın kullanacağı boş constructor
  CreditCard();

  // Veri ataması için constructor (Şifreleme/Çözme HiveService'de yapılacak)
  CreditCard.decrypted({
    required this.cardName,
    required this.statementDate,
    required this.dueDate,
  }) {
    // Şifreli alanlar HiveService içinde doldurulacak
    encryptedCardName = '';
    encryptedStatementDate = '';
    encryptedDueDate = '';
  }

   // Veri ataması için constructor (Şifreleme/Çözme HiveService'de yapılacak)
  CreditCard.encrypted({
    required this.encryptedCardName,
    required this.encryptedStatementDate,
    required this.encryptedDueDate,
  }) {
    // Şifresi çözülmüş alanlar HiveService içinde doldurulacak
    cardName = '';
    statementDate = '';
    dueDate = '';
  }


  @override
  String toString() {
    // Ekranda veya loglarda gösterirken şifresi çözülmüş halini kullanalım
    return 'CreditCard{cardName: $cardName, statementDate: $statementDate, dueDate: $dueDate}';
  }
}