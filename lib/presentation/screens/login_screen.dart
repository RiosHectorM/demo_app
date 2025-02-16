import 'dart:convert';
import 'package:demo_app/models/usuarios.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:crypto/crypto.dart'; // Para el hashing de contraseñas
import 'package:provider/provider.dart';
import '../../providers/usuarios_provider.dart';

class LoginScreen extends StatelessWidget {
  static const name = 'login-screen';
  const LoginScreen({super.key});

  // Loading time
  Duration get loadingTime => const Duration(milliseconds: 2000);

  // Función para hashear la contraseña
  String _hashPassword(String password) {
    var bytes = utf8.encode(password); // Convierte la contraseña a bytes
    var digest = sha256.convert(bytes); // Hashea la contraseña
    return digest.toString();
  }

  // Login
  Future<String?> _authUser(LoginData data, BuildContext context) async {
    var box =
        await Hive.openBox<Usuarios>('usuarios'); // Abrir la caja de usuarios

    for (var user in box.values) {
      if (user.email == data.name &&
          user.password == _hashPassword(data.password)) {
        // Si el login es exitoso, actualizar el usuario logueado en el provider
        Provider.of<UsuariosProvider>(context, listen: false)
            .setCurrentUser(user);

        return null; // Login exitoso
      }
    }

    return 'User not authorized'; // Si no se encuentra el usuario
  }

  // Forgot Password
  Future<String?> _recoverPassword(String name) {
    debugPrint('Name: $name');
    return Future.delayed(loadingTime).then((_) {
      //! Lógica para recuperar contraseña
      if (name.isEmpty) {
        return 'User not exists';
      }
      return null;
    });
  }

  // Signup
  Future<String?> _signupUser(SignupData data, BuildContext context) async {
    debugPrint('Signup Name: ${data.name}, Password: ${data.password}');

    // Abrir la caja de usuarios
    var box = await Hive.openBox<Usuarios>('usuarios');

    // Verificar si el email ya está registrado
    for (var user in box.values) {
      if (user.email == data.name) {
        return 'Email already registered';
      }
    }

    // Si no está registrado, guardar el nuevo usuario
    var newUser = Usuarios(
      id: DateTime.now()
          .millisecondsSinceEpoch
          .toString(), // Generar un ID único
      email: data.name!,
      password: _hashPassword(data.password!), // Guardar la contraseña hasheada
    );

    await box.add(newUser); // Guardar el usuario en la caja

    // Actualizar el usuario logueado en el provider
    Provider.of<UsuariosProvider>(context, listen: false)
        .setCurrentUser(newUser);

    return null; // Registro exitoso
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: FlutterLogin(
        title: 'Demo Xionico',
        theme: LoginTheme(
          primaryColor: colors.primary,
          accentColor: colors.inversePrimary,
        ),
        onLogin: (data) =>
            _authUser(data, context), // Pasar el contexto a _authUser
        onRecoverPassword: _recoverPassword,
        onSignup: (data) => _signupUser(data, context),
        onSubmitAnimationCompleted: () {
          // Redirigir al HomeScreen después de la animación de submit (registro exitoso)
          context.goNamed('home');
        },
      ),
    );
  }
}
