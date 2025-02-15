import 'package:demo_app/presentation/screens/clientes/clientes_list.dart';
import 'package:demo_app/presentation/screens/screens.dart';
import 'package:demo_app/presentation/screens/ventas/productos_screen.dart';
import 'package:go_router/go_router.dart';

final appRouter = GoRouter(
  initialLocation: '/login', // Mantén la ruta inicial en login
  routes: [
    GoRoute(
      path: '/login',
      name: LoginScreen.name,
      builder: (context, GoRouterState state) {
        return const LoginScreen();
      },
      routes: [
        GoRoute(
          path: 'home',
          builder: (context, GoRouterState state) {
            return const HomeScreen();
          },
          // Agrega la navegación a otras pantallas desde Home
          routes: [
            GoRoute(
              path: 'clienteslist',
              builder: (context, GoRouterState state) {
                return ClientesScreen();
              },
            ),
            GoRoute(
              path: '/productos/:nombreCliente',
              builder: (context, state) {
                final String nombreCliente =
                    Uri.decodeComponent(state.pathParameters['nombreCliente']!);
                return ProductosScreen(nombre: nombreCliente);
              },
            ),
          ],
        ),
      ],
    ),
  ],
);
