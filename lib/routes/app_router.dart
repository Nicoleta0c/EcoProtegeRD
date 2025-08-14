import 'package:go_router/go_router.dart';
import 'package:medioambienterd/screens/home.dart';
import 'routes.dart';


final GoRouter appRouter = GoRouter(
  routes: [
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const HomePage(),
    ),
  ],
);
