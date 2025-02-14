// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clientes.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ClientesAdapter extends TypeAdapter<Clientes> {
  @override
  final int typeId = 0;

  @override
  Clientes read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Clientes(
      icono: fields[0] as String,
      direccion: fields[2] as String,
      categoria: fields[3] as String,
      nombre: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Clientes obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.icono)
      ..writeByte(1)
      ..write(obj.nombre)
      ..writeByte(2)
      ..write(obj.direccion)
      ..writeByte(3)
      ..write(obj.categoria);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClientesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
