import 'package:hive/hive.dart';
import 'package:flutter/material.dart';
import '../models/usuarios.dart'; // Asegúrate de importar el archivo usuarios.dart

class UsuariosProvider with ChangeNotifier {
  late Box<Usuarios> _usuariosBox;

  late Usuarios? _currentUser;

  // Método para inicializar Hive
  Future<void> initHive() async {
    var box = await Hive.openBox<Usuarios>('usuarios');
    _loadUser(box);
  }

  // Método para cargar el usuario desde Hive (cuando la app se inicie)
  void _loadUser(Box<Usuarios> box) {
    if (box.isNotEmpty) {
      _currentUser =
          box.getAt(0)!; // Carga el primer usuario (o el que sea adecuado)
    } else {
      _currentUser =
          Usuarios(id: '', email: '', password: ''); // Usuario por defecto
    }
    notifyListeners();
  }

  // Método para actualizar el usuario logueado
  void setCurrentUser(Usuarios? user) {
    _currentUser = user;
    notifyListeners();
  }

  // Getter para obtener el usuario actual
  Usuarios get currentUser => _currentUser!;

  // Agregar un usuario
  Future<void> agregarUsuario(Usuarios usuario) async {
    await _usuariosBox.add(usuario);
    notifyListeners();
  }

  // Validar login de un usuario
  Future<String?> validarLogin(String email, String password) async {
    final usuario = _usuariosBox.values.firstWhere(
      (user) => user.email == email,
      orElse: () => Usuarios(id: '', email: '', password: ''),
    );

    if (usuario.id.isEmpty) {
      return 'Usuario no encontrado';
    }

    if (usuario.password != password) {
      return 'Contraseña incorrecta';
    }

    return null; // Login exitoso
  }
}
