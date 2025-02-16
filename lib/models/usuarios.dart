import 'package:hive/hive.dart';

part 'usuarios.g.dart';

@HiveType(
    typeId: 2) // Cambié el typeId para evitar conflictos con el modelo Clientes
class Usuarios {
  @HiveField(0)
  String id;

  @HiveField(1)
  String email;

  @HiveField(2)
  String password;

  Usuarios({
    required this.id,
    required this.email,
    required this.password,
  });
}
