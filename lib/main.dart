import 'package:flutter/material.dart';
import 'package:demo_app/config/theme/app_theme.dart';
import 'package:demo_app/config/router/app_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:demo_app/providers/productos_provider.dart';

import 'package:demo_app/providers/clientes_provider.dart';
import 'package:demo_app/providers/usuarios_provider.dart';
import 'models/clientes.dart'; // Asegúrate de que esté importado
import 'models/usuarios.dart'; // Asegúrate de que esté importado

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // Registra los adaptadores de los modelos
  Hive.registerAdapter(ClientesAdapter());
  Hive.registerAdapter(UsuariosAdapter());

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    cargarproductos();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) {
            final clientesProvider = ClientesProvider();
            final usuariosProvider = UsuariosProvider();
            clientesProvider.initHive();
            usuariosProvider.initHive();
            return clientesProvider; // Regresa uno de los proveedores si es necesario
          },
        ),
        ChangeNotifierProvider(
          create: (context) {
            final usuariosProvider = UsuariosProvider();
            usuariosProvider.initHive();
            return usuariosProvider; // Asegúrate de que ambos estén accesibles
          },
        ),
      ],
      child: MaterialApp.router(
        routerConfig: appRouter,
        debugShowCheckedModeBanner: false,
        theme: AppTheme().getTheme(),
      ),
    );
  }
}
