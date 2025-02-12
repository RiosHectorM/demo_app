import 'package:flutter/material.dart';
import 'package:demo_app/presentation/widgets/shared/custom_bottom_navigation.dart';


class LoginScreen extends StatelessWidget {
  static const name = 'login-screen';
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: Center(
        child: Scaffold(
          appBar: AppBar(title: Text("hola")),
          body: Placeholder(),
        ),
      ),
      bottomNavigationBar: CustomBottomNavigation(),
    );
  }
}

