import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/usuarios_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  static const name = 'home';

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colors.primary,
      appBar: AppBar(title: Text("Demo Xionico App")),
      body: _BodyHome(colors: colors), // Pasamos el esquema de colores
      drawer: _DrawerMenu(colors: colors),
    );
  }
}

class _DrawerMenu extends StatelessWidget {
  final ColorScheme colors;
  const _DrawerMenu({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          Consumer<UsuariosProvider>(
            builder: (context, usuariosProvider, child) {
              // Si no hay usuario logueado, redirigimos al login
              if (usuariosProvider.currentUser == null) {
                Future.microtask(() => context
                    .goNamed('login-screen')); // Redirigir inmediatamente
                return DrawerHeader(
                  decoration: BoxDecoration(color: colors.primary),
                  child: Center(
                    child: Text("No user logged in"),
                  ),
                );
              }

              return DrawerHeader(
                decoration: BoxDecoration(color: colors.primary),
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        "Menú de Opciones",
                        style: TextStyle(
                            color: colors.inversePrimary, fontSize: 20),
                      ),
                      SizedBox(height: 50),
                      // Mostrar el email del usuario logueado
                      Text(usuariosProvider.currentUser!
                          .email), // Asegurarnos de que currentUser no es null
                    ],
                  ),
                ),
              );
            },
          ),
          FadeInLeft(
            delay: Duration(milliseconds: 100),
            child: ListTile(
                leading: Icon(Icons.people_alt),
                title: Text("CLIENTES"),
                onTap: () => context.goNamed('clienteslist')),
          ),
          FadeInLeft(
            delay: Duration(milliseconds: 150),
            child: ExpansionTile(
              leading: Icon(Icons.receipt_outlined),
              title: Text("REPORTES"),
              children: [
                ListTile(
                    leading: Icon(Icons.monetization_on_sharp),
                    title: Text("Reporte de Ventas"),
                    onTap: () => context.goNamed('reportes')),
              ],
            ),
          ),
          FadeInLeft(
            delay: Duration(milliseconds: 200),
            child: ExpansionTile(
              leading: Icon(Icons.map_outlined),
              title: Text("MAPAS"),
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.pin_drop_outlined),
                  title: Text("Mapa de Ventas"),
                  onTap: () => context.goNamed('mapas'),
                ),
              ],
            ),
          ),
          FadeInLeft(
            delay: Duration(milliseconds: 250),
            child: ListTile(
              leading: Icon(Icons.send_to_mobile_outlined),
              title: Text("ENVIAR DATOS"),
              onTap: () => context.goNamed('enviar'),
            ),
          ),
          FadeInLeft(
            delay: Duration(milliseconds: 300),
            child: ListTile(
              leading: Icon(Icons.output_rounded),
              title: Text("CERRAR SESION"),
              onTap: () async {
                try {
                  // Establecer currentUser a null
                  Provider.of<UsuariosProvider>(context, listen: false)
                      .setCurrentUser(null);

                  // Esperar un poco para asegurarnos de que la UI se actualice
                  await Future.delayed(Duration(milliseconds: 300));

                  // Redirigir a la pantalla de login
                  context.goNamed('login-screen');
                } catch (e) {
                  print('Error al cerrar sesión: $e');
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _BodyHome extends StatelessWidget {
  final ColorScheme colors;

  const _BodyHome({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          Text(
            "Bienvenido al Sistema..!!!",
            style: TextStyle(fontSize: 24, color: colors.inversePrimary),
          ),
        ],
      ),
    );
  }
}
