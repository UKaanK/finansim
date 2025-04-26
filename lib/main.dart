/*
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Kopyalama için

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
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueGrey,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: Colors.black,
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
    'Ziraat Bankası':
        'https://images.seeklogo.com/logo-png/15/2/ziraat-bankasi-logo-png_seeklogo-156296.png',
    'İş Bankası':
        'https://images.seeklogo.com/logo-png/14/1/turkiye-is-bankasi-logo-png_seeklogo-143248.png',
    'Garanti BBVA':
        'https://e7.pngegg.com/pngimages/206/545/png-clipart-garanti-bank-turkiye-İş-bankası-credit-finance-bank-text-trademark.png',
    'Akbank':
        'https://upload.wikimedia.org/wikipedia/commons/0/02/Akbank_logo.png',
    'Yapı Kredi':
        'https://upload.wikimedia.org/wikipedia/commons/8/86/Yap%C4%B1_Kredi_logo.png',
  };

  void _openAddIbanModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      isScrollControlled: true,
      builder: (context) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: AddIbanForm(onSave: (iban, bank, owner) {
          setState(() {
            ibans.add({'iban': iban, 'bank': bank, 'owner': owner});
          });
          Navigator.pop(context);
        }),
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
                : ListView.builder(
                    itemCount: ibans.length,
                    itemBuilder: (context, index) {
                      final ibanData = ibans[index];
                      String? logoUrl = bankLogos[ibanData['bank']];
                      return Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blueGrey.shade900,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            logoUrl != null
                                ? Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                        image: NetworkImage(logoUrl),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  )
                                : const CircleAvatar(
                                    radius: 30,
                                    backgroundColor: Colors.grey,
                                    child: Icon(Icons.account_balance,
                                        color: Colors.white),
                                  ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    ibanData['owner'] ?? '',
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    ibanData['iban'] ?? '',
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.white70),
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
                              icon:
                                  const Icon(Icons.copy, color: Colors.white70),
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

  final List<String> banks = [
    'Ziraat Bankası',
    'İş Bankası',
    'Garanti BBVA',
    'Akbank',
    'Yapı Kredi',
  ];

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      String cleanedIban =
          _ibanController.text.replaceAll(' ', '').toUpperCase();
      widget.onSave(
        cleanedIban,
        _selectedBank!,
        _ownerController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _ownerController,
                decoration: const InputDecoration(
                  labelText: 'Hesap Sahibi Adı',
                  border: OutlineInputBorder(),
                ),
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
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Banka Seçin',
                  border: OutlineInputBorder(),
                ),
                items: banks.map((bank) {
                  return DropdownMenuItem(
                    value: bank,
                    child: Text(bank),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedBank = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Banka seçin.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
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
*/

/*
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
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueGrey,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: Colors.black,
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
    'Ziraat Bankası':
        'https://www.ziraatbank.com.tr/PublishingImages/Subpage/bankamiz/BankamizGorselleri/Ziraat_Bankasi_Logo_JPEG.jpg',
    'İş Bankası':
        'https://companieslogo.com/img/orig/ISCTR.IS-98650725.png?t=1720244492',
    'Garanti BBVA':
        'https://foto.sondakika.com/haber/2019/04/25/garanti-bankasi-nin-ismi-degisti-yeni-isim-ga-11984935_amp.jpg',
    'Akbank':
        'https://upload.wikimedia.org/wikipedia/commons/0/02/Akbank_logo.png',
    'Yapı Kredi':
        'https://upload.wikimedia.org/wikipedia/commons/8/86/Yap%C4%B1_Kredi_logo.png',
  };

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
                : ListView.builder(
                    itemCount: ibans.length,
                    itemBuilder: (context, index) {
                      final ibanData = ibans[index];
                      final logoUrl = bankLogos[ibanData['bank']];
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
                            logoUrl != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(50),
                                    child: Image.network(
                                      logoUrl,
                                      width: 70,
                                      height: 70,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Container(
                                          width: 70,
                                          height: 70,
                                          color: Colors.grey,
                                          child: const Icon(Icons.error,
                                              color: Colors.white),
                                        );
                                      },
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
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                        fontSize: 14, color: Colors.white70),
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
                              icon:
                                  const Icon(Icons.copy, color: Colors.white70),
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
    'Ziraat Bankası':
        'https://upload.wikimedia.org/wikipedia/commons/8/80/Ziraat_Bankas%C4%B1_logo.png',
    'İş Bankası':
        'https://companieslogo.com/img/orig/ISCTR.IS-98650725.png?t=1720244492',
    'Garanti BBVA':
        'https://foto.sondakika.com/haber/2019/04/25/garanti-bankasi-nin-ismi-degisti-yeni-isim-ga-11984935_amp.jpg',
    'Akbank':
        'https://upload.wikimedia.org/wikipedia/commons/0/02/Akbank_logo.png',
    'Yapı Kredi':
        'https://upload.wikimedia.org/wikipedia/commons/8/86/Yap%C4%B1_Kredi_logo.png',
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
                child: Image.network(
                  entry.value,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 50,
                      height: 50,
                      color: Colors.grey,
                      child: const Icon(Icons.error, color: Colors.white),
                    );
                  },
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
              Text(
                'Yeni IBAN Ekle',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
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
                              child: Image.network(
                                banks[_selectedBank]!,
                                width: 40,
                                height: 40,
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


*/

/*

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
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueGrey,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: Colors.black,
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
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                        fontSize: 14, color: Colors.white70),
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
                              icon:
                                  const Icon(Icons.copy, color: Colors.white70),
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


*/

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
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueGrey,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: Colors.black,
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
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                        fontSize: 14, color: Colors.white70),
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
                              icon:
                                  const Icon(Icons.copy, color: Colors.white70),
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
