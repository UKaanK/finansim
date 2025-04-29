

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IBAN Takip',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.dark(
          primary: const Color.fromARGB(255, 255, 201, 100),
          secondary: Colors.blueGrey,
          background: Colors.black,
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardColor: const Color(0xFF1E1E1E),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.tealAccent.shade400,
            foregroundColor: Colors.black,
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.tealAccent,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Colors.tealAccent),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: const Color(0xFF1A1A1A),
          selectedItemColor: Colors.tealAccent,
          unselectedItemColor: Colors.white54,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white10,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          labelStyle: const TextStyle(color: Colors.white70),
        ),
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: Colors.tealAccent,
          contentTextStyle: TextStyle(color: Colors.black),
        ),
      ),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: IbanListScreen(),
    );
  }
}

class IbanListScreen extends StatefulWidget {
  const IbanListScreen({super.key});

  @override
  State<IbanListScreen> createState() => _IbanListScreenState();
}

class _IbanListScreenState extends State<IbanListScreen> {
  List<Map<String, String>> ibans = [];
  final Map<String, String> bankLogos = {
    'Ziraat Bankası': 'assets/images/ziraat.jpg',
    'İş Bankası': 'assets/images/isbank.png',
    'Garanti BBVA': 'assets/images/garanti.png',
    'Akbank': 'assets/images/akbank.png',
    'Yapı Kredi': 'assets/images/yapikredi.png',
  };
  bool showAsCards = false;

  void _openAddIbanModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black.withOpacity(0.7),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => AddIbanForm(
        onSave: (iban, bank, owner) {
          setState(() {
            ibans.add({'iban': iban, 'bank': bank, 'owner': owner});
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  void _copyIban(String iban) {
    Clipboard.setData(ClipboardData(text: iban));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('IBAN kopyalandı')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IBAN Listesi'),
        actions: [
          IconButton(
            icon: Icon(showAsCards ? Icons.list : Icons.view_agenda),
            tooltip: "Görünümü Değiştir",
            onPressed: () {
              setState(() {
                showAsCards = !showAsCards;
              });
            },
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.blueGrey.shade900,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'IBAN'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Ayarlar'),
        ],
        currentIndex: 0,
        onTap: (index) {},
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: _openAddIbanModal,
              icon: const Icon(Icons.add),
              label: const Text('Yeni IBAN Ekle'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          Expanded(
            child: ibans.isEmpty
                ? const Center(child: Text('Henüz IBAN eklenmedi.'))
                : showAsCards
                    ? PageView.builder(
                        itemCount: ibans.length,
                        itemBuilder: (context, index) {
                          final iban = ibans[index];
                          final logo = bankLogos[iban['bank']];
                          return Padding(
                            padding: const EdgeInsets.all(20),
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              color: Colors.blueGrey.shade800,
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    logo != null
                                        ? Image.asset(logo,
                                            height: 70, fit: BoxFit.contain)
                                        : const Icon(Icons.account_balance,
                                            size: 70, color: Colors.white),
                                    const SizedBox(height: 20),
                                    Text(
                                      iban['owner'] ?? '',
                                      style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      iban['iban'] ?? '',
                                      style: const TextStyle(
                                          fontSize: 18, color: Colors.white70),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      iban['bank'] ?? '',
                                      style: const TextStyle(
                                          fontSize: 14, color: Colors.grey),
                                    ),
                                    const SizedBox(height: 16),
                                    ElevatedButton.icon(
                                      onPressed: () => _copyIban(iban['iban']!),
                                      icon: const Icon(Icons.copy),
                                      label: const Text('Kopyala'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.teal,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      )
                    : ListView.builder(
                        itemCount: ibans.length,
                        itemBuilder: (context, index) {
                          final ibanData = ibans[index];
                          final logoPath = bankLogos[ibanData['bank']];
                          return Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.blueGrey.shade900,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                logoPath != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(50),
                                        child: Image.asset(
                                          logoPath,
                                          width: 70,
                                          height: 70,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : const CircleAvatar(
                                        radius: 35,
                                        backgroundColor: Colors.grey,
                                        child: Icon(Icons.account_balance,
                                            color: Colors.white),
                                      ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        ibanData['owner'] ?? '',
                                        style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        ibanData['iban'] ?? '',
                                        style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.white70),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        ibanData['bank'] ?? '',
                                        style: const TextStyle(
                                            fontSize: 12, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => _copyIban(ibanData['iban']!),
                                  icon: const Icon(Icons.copy,
                                      color: Colors.white70),
                                  tooltip: 'Kopyala',
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class AddIbanForm extends StatefulWidget {
  final void Function(String iban, String bank, String owner) onSave;

  const AddIbanForm({super.key, required this.onSave});

  @override
  State<AddIbanForm> createState() => _AddIbanFormState();
}

class _AddIbanFormState extends State<AddIbanForm> {
  final _formKey = GlobalKey<FormState>();
  final _ibanController = TextEditingController();
  final _ownerController = TextEditingController();
  String? _selectedBank;

  final Map<String, String> banks = {
    'Ziraat Bankası': 'assets/images/ziraat.jpg',
    'İş Bankası': 'assets/images/isbank.png',
    'Garanti BBVA': 'assets/images/garanti.png',
    'Akbank': 'assets/images/akbank.png',
    'Yapı Kredi': 'assets/images/yapikredi.png',
  };

  void _saveForm() {
    if (_formKey.currentState!.validate() && _selectedBank != null) {
      String cleanedIban =
          _ibanController.text.replaceAll(' ', '').toUpperCase();
      widget.onSave(
        cleanedIban,
        _selectedBank!,
        _ownerController.text,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen tüm alanları doldurun')),
      );
    }
  }

  void _selectBankDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.blueGrey.shade900,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: banks.entries.map((entry) {
            return ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  entry.value,
                  width: 100,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
              title: Text(
                entry.key,
                style: const TextStyle(color: Colors.white),
              ),
              onTap: () {
                setState(() {
                  _selectedBank = entry.key;
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        top: 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Yeni IBAN Ekle',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _ownerController,
                decoration: const InputDecoration(
                  labelText: 'Hesap Sahibi Adı',
                  border: OutlineInputBorder(),
                ),
                style: const TextStyle(color: Colors.white),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Hesap sahibi adını girin.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ibanController,
                decoration: const InputDecoration(
                  labelText: 'IBAN Numarası',
                  border: OutlineInputBorder(),
                ),
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9 ]')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'IBAN girin.';
                  }
                  String iban = value.replaceAll(' ', '').toUpperCase();
                  if (!iban.startsWith('TR')) {
                    return 'IBAN \"TR\" ile başlamalı.';
                  }
                  if (iban.length != 26) {
                    return 'IBAN 26 karakter olmalı.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _selectBankDialog,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white70),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      _selectedBank != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                banks[_selectedBank]!,
                                width: 100,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Icon(Icons.account_balance,
                              color: Colors.white70),
                      const SizedBox(width: 16),
                      Text(
                        _selectedBank ?? 'Banka Seçin',
                        style: const TextStyle(color: Colors.white),
                      ),
                      const Spacer(),
                      const Icon(Icons.arrow_drop_down, color: Colors.white70),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveForm,
                child: const Text('Kaydet'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
