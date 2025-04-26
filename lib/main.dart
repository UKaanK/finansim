import 'package:finansim/models/iban.dart';
import 'package:finansim/models/credit_card.dart'; 
import 'package:finansim/services/hive_service.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';
import 'package:finansim/providers/iban_provider.dart';
import 'package:finansim/providers/credit_card_provider.dart'; // CreditCardProvider'ı import et

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  
  Hive.registerAdapter(IBANAdapter());
  Hive.registerAdapter(CreditCardAdapter()); 

  var ibanBox = await Hive.openBox<IBAN>('ibans');
  var creditCardBox = await Hive.openBox<CreditCard>('credit_cards'); 
  
  var hiveService = HiveService(ibanBox: ibanBox, creditCardBox: creditCardBox);
  
  // Test verileri
  await hiveService.clearIBANs(); 
  await hiveService.addIBAN("YapıKredi","TR123456");
  await hiveService.clearCreditCards();
  await hiveService.addCreditCard(cardName: "Banka X Gold", statementDate: "15", dueDate: "25");
  await hiveService.addCreditCard(cardName: "Banka Y Platinum", statementDate: "10", dueDate: "20"); // İkinci kart ekleyelim


  runApp(
    MultiProvider( // Birden fazla provider için MultiProvider
      providers: [
        ChangeNotifierProvider(create: (context) => IBANProvider(hiveService)),
        ChangeNotifierProvider(create: (context) => CreditCardProvider(hiveService)), // CreditCardProvider'ı ekle
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}
// ... (önceki kod aynı) ...

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}
// ... (önceki kod aynı) ...

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Verileri yükle
    Provider.of<IBANProvider>(context, listen: false).fetchIBANs(); 
    Provider.of<CreditCardProvider>(context, listen: false).fetchCreditCards(); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Başlığı genel yapalım
        title: Text('Finansım'), 
      ),
      // Consumer2 ile iki provider'ı da dinleyelim
      body: Consumer2<IBANProvider, CreditCardProvider>( 
        builder: (context, ibanProvider, creditCardProvider, child) {
          
          // İki provider'dan biri bile yüklüyorsa gösterge göster
          if (ibanProvider.isLoading || creditCardProvider.isLoading) { 
            return Center(child: CircularProgressIndicator());
          } 
          
          // Veri yoksa mesaj göster
          if (ibanProvider.ibans.isEmpty && creditCardProvider.creditCards.isEmpty) { 
            return Center(child: Text('Hiç IBAN veya Kredi Kartı yok.'));
          }
          
          // Gösterilecek tüm widget'ları tutacak liste
          List<Widget> listItems = [];

          // --- IBAN Bölümü ---
          if (ibanProvider.ibans.isNotEmpty) {
            // IBAN Başlığı
            listItems.add(
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text('IBANlarım', style: Theme.of(context).textTheme.titleLarge),
              )
            );
            // IBAN Listesi
            listItems.addAll(
              ibanProvider.ibans.map((iban) => ListTile(
                leading: Icon(Icons.account_balance_wallet_outlined), // IBAN ikonu
                title: Text(iban.title),
                subtitle: Text(iban.ibanNumber),
                // İstenirse IBAN için de silme eklenebilir
              )).toList(),
            );
             // Bölümler arasına ayırıcı ekleyelim
             listItems.add(Divider(thickness: 1));
          }

          // --- Kredi Kartı Bölümü ---
          if (creditCardProvider.creditCards.isNotEmpty) {
             // Kredi Kartı Başlığı
            listItems.add(
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text('Kredi Kartlarım', style: Theme.of(context).textTheme.titleLarge),
              )
            );
             // Kredi Kartı Listesi
            listItems.addAll(
              creditCardProvider.creditCards.map((card) {
                return ListTile(
                   leading: Icon(Icons.credit_card), // Kredi Kartı ikonu
                  title: Text(card.cardName), 
                  subtitle: Text('Ekstre: ${card.statementDate}, Son Ödeme: ${card.dueDate}'),
                  trailing: IconButton(
                    icon: Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text('Emin misiniz?'),
                          content: Text('${card.cardName} kartını silmek istediğinize emin misiniz?'),
                          actions: <Widget>[
                            TextButton(child: Text('İptal'), onPressed: () => Navigator.of(ctx).pop()),
                            TextButton(
                              child: Text('Sil', style: TextStyle(color: Colors.red)),
                              onPressed: () {
                                if (card.key != null) {
                                   creditCardProvider.deleteCreditCard(card.key);
                                } else {
                                   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Kart silinemedi: Anahtar bulunamadı.')));
                                }
                                Navigator.of(ctx).pop();
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              }).toList(),
            );
          }

          // Oluşturulan tüm widget'ları tek bir ListView içinde göster
          return ListView.builder(
            itemCount: listItems.length,
            itemBuilder: (context, index) {
              return listItems[index];
            },
          );
        },
      ),
      // İstenirse genel bir ekleme butonu eklenebilir
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     // Ekleme menüsü veya sayfası
      //   },
      //   child: Icon(Icons.add),
      // ),
    );
  }
}