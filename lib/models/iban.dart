import 'package:hive/hive.dart';
@HiveType(typeId: 0)
class IBAN {
  @HiveField(0)
  final String title;
  
  @HiveField(1)
  final String ibanNumber;
  
  IBAN({required this.title, required this.ibanNumber});
  @override
String toString() {
  return 'IBAN{title: $title, ibanNumber: $ibanNumber}';
}
}

// Adapter sınıfını tanımlayın
class IBANAdapter extends TypeAdapter<IBAN> {
  @override
  final int typeId = 0;

  @override
  IBAN read(BinaryReader reader) {
    final title = reader.readString();
    final ibanNumber = reader.readString();
    return IBAN(title: title, ibanNumber: ibanNumber);
  }

  @override
  void write(BinaryWriter writer, IBAN obj) {
    writer.writeString(obj.title);
    writer.writeString(obj.ibanNumber);
  }
  
}
