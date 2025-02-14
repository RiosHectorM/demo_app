import 'package:demo_app/presentation/screens/clientes/clientes_list.dart';
import 'package:demo_app/presentation/screens/screens.dart';
import 'package:go_router/go_router.dart';

final appRouter = GoRouter(initialLocation: '/', routes: [
  GoRoute(
      path: '/',
      name: LoginScreen.name,
      builder: (context, GoRouterState state) {
        return const LoginScreen();
      },
      routes: [
        GoRoute(
          path: 'home',
          builder: (context, GoRouterState state) {
            return const HomeScreen();
          },),
        GoRoute(
          path: 'clienteslist',
          builder: (context, GoRouterState state) {
            return  ClientesScreen();
          },)
      ]),
]);
