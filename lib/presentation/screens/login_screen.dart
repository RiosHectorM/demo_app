import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatelessWidget {
  static const name = 'login-screen';
  const LoginScreen({super.key});

  //Loading time
  Duration get loadingTime => const Duration(milliseconds: 2000);

  // Redirección luego de login exitoso
  void onLoginSuccess(BuildContext context) {
    // Una vez que el login sea exitoso, navega directamente a Home sin dejar que se vuelva atrás al LoginScreen
    context.goNamed('home');
  }

  //Login
  Future<String?> _authUser(LoginData data) {
    return Future.delayed(loadingTime).then((_) {
      //! Verificar data con usuarios en DB
      if (data.name != "user@mail.com" || data.password != "1234") {
        return 'User not authorized';
      }
      return null;
    });
  }

  //Forgot Password
  Future<String?> _recoverPassword(String name) {
    debugPrint('Name: $name');
    return Future.delayed(loadingTime).then((_) {
      //! Logica para recuperar password
      if (name.isEmpty) {
        return 'User not exists';
      }
      return null;
    });
  }

  //SingUp
  Future<String?> _signupUser(SignupData data) {
    debugPrint('Signup Name: ${data.name}, Password: ${data.password}');
    return Future.delayed(loadingTime).then((_) {
      //! Logica para grabar datos usuario en DB
      return null;
    });
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
        onLogin: _authUser,
        onRecoverPassword: _recoverPassword,
        onSignup: _signupUser,
        onSubmitAnimationCompleted: () {
          // Redirigir al HomeScreen después de la animación de submit (login exitoso)
          onLoginSuccess(context);
        },
      ),
    );
  }
}
