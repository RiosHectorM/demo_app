// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'usuarios.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UsuariosAdapter extends TypeAdapter<Usuarios> {
  @override
  final int typeId = 2;

  @override
  Usuarios read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Usuarios(
      id: fields[0] as String,
      email: fields[1] as String,
      password: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Usuarios obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.email)
      ..writeByte(2)
      ..write(obj.password);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UsuariosAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
