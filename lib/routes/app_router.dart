import 'package:go_router/go_router.dart';
import 'package:medioambienterd/screens/mainPage/home.dart';
import 'package:medioambienterd/screens/mainPage/about_us.dart';
import 'package:medioambienterd/screens/Service/services.dart';
import 'package:medioambienterd/screens/mainPage/noticias.dart';
import 'package:medioambienterd/screens/mainPage/videos.dart';
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
