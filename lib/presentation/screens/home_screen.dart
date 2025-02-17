import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/usuarios_provider.dart';
import 'package:hive/hive.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  static const name = 'home';

  Future<void> limpiarBoxes(BuildContext context) async {
    try {
      // Abrir los boxes si no están abiertos
      var clientesBox = Hive.isBoxOpen('clientes')
          ? Hive.box('clientes')
          : await Hive.openBox('clientes');
      var productosBox = Hive.isBoxOpen('productos')
          ? Hive.box('productos')
          : await Hive.openBox('productos');
      var reportesBox = Hive.isBoxOpen('reportes')
          ? Hive.box('reportes')
          : await Hive.openBox('reportes');
      var ventasBox = Hive.isBoxOpen('ventas')
          ? Hive.box('ventas')
          : await Hive.openBox('ventas');

      // Borrar datos
      await clientesBox.clear();
      await productosBox.clear();
      await reportesBox.clear();
      await ventasBox.clear();

      await clientesBox.close();
      await productosBox.close();
      await reportesBox.close();
      await ventasBox.close();

      // Mostrar mensaje de confirmación
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Datos limpiados correctamente'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al limpiar datos: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    var floatingActionButton = FloatingActionButton(
      onPressed: () async => await limpiarBoxes(context),
      backgroundColor: Colors.red,
      tooltip: 'Borrar datos',
      child: Icon(Icons.delete_forever),
    );

    return Scaffold(
      backgroundColor: colors.primary,
      appBar: AppBar(title: Text("Demo Xionico App")),
      body: _BodyHome(colors: colors),
      drawer: _DrawerMenu(colors: colors),
      //floatingActionButton: floatingActionButton,
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
                      FadeIn(
                        child: Text(
                          usuariosProvider.currentUser != null
                              ? "Bienvenido, ${usuariosProvider.currentUser!.email}"
                              : "Bienvenido",
                          style: TextStyle(
                              color: colors.inversePrimary,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
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
                onTap: () => context.pushNamed('clienteslist')),
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
                    onTap: () => context.pushNamed('reportes')),
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
                  onTap: () => context.pushNamed('mapas'),
                ),
              ],
            ),
          ),
          FadeInLeft(
            delay: Duration(milliseconds: 250),
            child: ListTile(
              leading: Icon(Icons.send_to_mobile_outlined),
              title: Text("ENVIAR DATOS"),
              onTap: () => context.pushNamed('enviar'),
            ),
          ),
          FadeInLeft(
            delay: Duration(milliseconds: 300),
            child: ListTile(
              leading: Icon(Icons.output_rounded),
              title: Text("CERRAR SESION"),
              onTap: () async {
                // try {
                //   Provider.of<UsuariosProvider>(context, listen: false)
                //       .setCurrentUser(null);
                //   throw Exception(
                //       "Usuario después de cerrar sesión: ${Provider.of<UsuariosProvider>(context, listen: false).currentUser}");

                //    Esperar que la UI se actualice
                //   await Future.delayed(Duration(milliseconds: 300));

                // Redirigir al login
                context.goNamed('login-screen');
                // } catch (e) {
                //   print('Error al cerrar sesión: $e');
                // }
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
