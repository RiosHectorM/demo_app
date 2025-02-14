import 'package:flutter/material.dart';
import 'package:demo_app/config/theme/app_theme.dart';
import 'package:demo_app/config/router/app_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
//import 'models/clientes.dart';
import 'providers/clientes_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  runApp( MyApp());
}

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//  @override
//   Widget build(BuildContext context) {
//     return MaterialApp.router(
//       routerConfig: appRouter,
//       debugShowCheckedModeBanner: false,
//       theme: AppTheme().getTheme(),
//     );
//   }
// }

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        final provider = ClientesProvider();
        provider.initHive();
        return provider;
      },
      child: MaterialApp.router(
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
      theme: AppTheme().getTheme(),
    )
    );
  }
}