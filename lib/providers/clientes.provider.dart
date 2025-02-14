import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/clientes.dart';

class ClientesProvider with ChangeNotifier {
  late Box<Clientes> _clientesBox;

  List<Clientes> get clientes => _clientesBox.values.toList();

  Future<void> initHive() async {
    Hive.registerAdapter(ClientesAdapter());
    _clientesBox = await Hive.openBox<Clientes>('clientesBox');
    notifyListeners();
  }

  void addCliente(String icono, String nombre, String direccion, String categoria) {
    final cliente = Clientes(icono: icono, nombre: nombre, direccion: direccion, categoria: categoria);
    _clientesBox.add(cliente);
    notifyListeners();
  }

  void updateCliente(int index, String icono, String nombre, String direccion, String categoria) {
    final cliente = _clientesBox.getAt(index);
    if (cliente != null) {
      cliente.icono = icono;
      cliente.nombre = nombre;
      cliente.direccion = direccion;
      cliente.categoria = categoria;
      cliente.save();
      notifyListeners();
    }
  }

  void deleteCliente(int index) {
    _clientesBox.deleteAt(index);
    notifyListeners();
  }
}
