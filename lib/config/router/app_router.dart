import 'package:demo_app/presentation/screens/clientes/clientes_list.dart';
import 'package:demo_app/presentation/screens/screens.dart';
import 'package:demo_app/presentation/screens/ventas/ventas_map_screen.dart';
import 'package:demo_app/presentation/screens/ventas/productos_screen.dart';
import 'package:demo_app/presentation/screens/ventas/reportes_screen.dart';
import 'package:go_router/go_router.dart';

final appRouter = GoRouter(
  initialLocation: '/login', // Ruta inicial
  routes: [
    GoRoute(
      path: '/login',
      name: LoginScreen.name,
      builder: (context, GoRouterState state) {
        return const LoginScreen();
      },
    ),
    GoRoute(
      path: '/home',
      name: 'home', // Ruta para la pantalla principal después del login
      builder: (context, GoRouterState state) {
        return const HomeScreen();
      },
    ),
    GoRoute(
      path: '/clienteslist',
      name: 'clienteslist',
      builder: (context, GoRouterState state) {
        return ClientesScreen();
      },
    ),
    GoRoute(
      path: '/productos/:nombreCliente/:direccionCliente',
      name: 'productos',
      builder: (context, state) {
        final String nombreCliente =
            Uri.decodeComponent(state.pathParameters['nombreCliente']!);
        final String direccionCliente =
            Uri.decodeComponent(state.pathParameters['direccionCliente']!);

        return ProductosScreen(
          nombre: nombreCliente,
          direccion: direccionCliente,
        );
      },
    ),
    GoRoute(
      path: '/reportes',
      name: 'reportes',
      builder: (context, GoRouterState state) {
        return ReportesScreen();
      },
    ),
    GoRoute(
      path: '/mapas',
      name: 'mapas',
      builder: (context, GoRouterState state) {
        return MapaVentasScreen();
      },
    )
  ],
);
