import 'package:go_router/go_router.dart';
import 'package:medioambienterd/screens/home.dart';
import 'package:medioambienterd/screens/about_us.dart';
import 'package:medioambienterd/screens/services.dart';
import 'package:medioambienterd/screens/noticias.dart';
import 'package:medioambienterd/screens/videos.dart';
import 'routes.dart';

final GoRouter appRouter = GoRouter(
  routes: [
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: AppRoutes.aboutUs,
      builder: (context, state) => const AboutUsPage(),
    ),
    GoRoute(
      path: AppRoutes.services,
      builder: (context, state) => const ServicesPage(),
    ),
    GoRoute(
      path: AppRoutes.noticias,
      builder: (context, state) => const NoticiasPage(),
    ),
    GoRoute(
      path: AppRoutes.videos,
      builder: (context, state) => const VideosPage(),
    ),
  ],
);
