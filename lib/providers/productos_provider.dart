import 'dart:convert';
import 'package:flutter/services.dart'; // Para cargar el archivo JSON
import 'package:hive/hive.dart';

Future<void> cargarproductos() async {
  final box = await Hive.openBox('productos');

  if (box.isEmpty) {
    String data = await rootBundle.loadString('assets/productos.json');
    List<dynamic> productos = json.decode(data);

    for (var producto in productos) {
      box.put(producto['ID'], producto);
    }
  }
}
