// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credit_card.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CreditCardAdapter extends TypeAdapter<CreditCard> {
  @override
  final int typeId = 1;

  @override
  CreditCard read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CreditCard()
      ..cardName = fields[0] as String
      ..statementDate = fields[1] as String
      ..dueDate = fields[2] as String
      ..encryptedCardName = fields[3] as String
      ..encryptedStatementDate = fields[4] as String
      ..encryptedDueDate = fields[5] as String;
  }

  @override
  void write(BinaryWriter writer, CreditCard obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.cardName)
      ..writeByte(1)
      ..write(obj.statementDate)
      ..writeByte(2)
      ..write(obj.dueDate)
      ..writeByte(3)
      ..write(obj.encryptedCardName)
      ..writeByte(4)
      ..write(obj.encryptedStatementDate)
      ..writeByte(5)
      ..write(obj.encryptedDueDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreditCardAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
