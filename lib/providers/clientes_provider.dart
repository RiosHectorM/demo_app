import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/clientes.dart';

class ClientesProvider extends ChangeNotifier {
  late Box<Clientes> _clientesBox;

  ClientesProvider() {
    _initBox();
  }

  Future<void> initHive() async {
    await Hive.openBox<Clientes>('clientes');
  }

  Future<void> _initBox() async {
    _clientesBox = await Hive.openBox<Clientes>('clientesBox');
    notifyListeners();
  }

  List<Clientes> get clientes => _clientesBox.values.toList();

  void addCliente(
      String icono, String nombre, String direccion, String categoria) {
    final nuevoCliente = Clientes(
        icono: icono,
        nombre: nombre,
        direccion: direccion,
        categoria: categoria);
    _clientesBox.add(nuevoCliente);
    notifyListeners();
  }

  void updateCliente(int index, String icono, String nombre, String direccion,
      String categoria) {
    final clienteActualizado = Clientes(
        icono: icono,
        nombre: nombre,
        direccion: direccion,
        categoria: categoria);
    _clientesBox.putAt(index, clienteActualizado);
    notifyListeners();
  }

  void deleteCliente(int index) {
    _clientesBox.deleteAt(index);
    notifyListeners();
  }
}
