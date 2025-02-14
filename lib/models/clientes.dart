import 'package:hive/hive.dart';

part 'clientes.g.dart';

@HiveType(typeId: 0)
class Clientes extends HiveObject {
  @HiveField(0)
  String icono;

  @HiveField(1)
  String nombre;

  @HiveField(2)
  String direccion;

  @HiveField(3)
  String categoria;


  Clientes({required this.icono, required this.direccion, required this.categoria,required this.nombre});
}
