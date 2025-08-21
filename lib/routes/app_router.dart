import 'package:go_router/go_router.dart';
import 'package:medioambienterd/screens/Reports/my_reports_screen.dart';
import 'package:medioambienterd/screens/Reports/report_damage_screen.dart';
import 'package:medioambienterd/screens/mainPage/home.dart';
import 'package:medioambienterd/screens/mainPage/about_us.dart';
import 'package:medioambienterd/screens/Service/services.dart';
import 'package:medioambienterd/screens/mainPage/noticias.dart';
import 'package:medioambienterd/screens/mainPage/videos.dart';
import 'package:medioambienterd/screens/Auth/login_screen.dart';
import 'package:medioambienterd/screens/Auth/register_screen.dart';
import 'package:medioambienterd/screens/AreasProtegidas/areas_protegidas_page.dart';
import 'package:medioambienterd/screens/AreasProtegidas/area_detalle_page.dart';
import 'package:medioambienterd/screens/AreasProtegidas/mapa_areas_page.dart';
import 'package:medioambienterd/screens/MedidasAmbientales/medidas_ambientales_page.dart';
import 'package:medioambienterd/screens/MedidasAmbientales/medida_detalle_page.dart';
import 'package:medioambienterd/screens/EquipoMinisterio/equipo_ministerio_page.dart';
import 'package:medioambienterd/screens/Voluntariado/voluntariado_page.dart';
import 'package:medioambienterd/screens/Voluntariado/registro_voluntario_page.dart';
import 'package:medioambienterd/screens/AcercaDe/acerca_de_page.dart';
import 'routes.dart';
import 'package:medioambienterd/utils/session.dart';


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
     GoRoute(
      path: AppRoutes.Login,
      builder: (context, state) => const LoginScreen(),
    ),
     GoRoute(
      path: AppRoutes.Register,
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: AppRoutes.areasProtegidas,
      builder: (context, state) => const AreasProtegidasPage(),
    ),
    GoRoute(
      path: AppRoutes.areaDetalle,
      builder: (context, state) {
        final areaId = state.uri.queryParameters['id'] ?? '';
        return AreaDetallePage(areaId: areaId);
      },
    ),
    GoRoute(
      path: AppRoutes.mapaAreas,
      builder: (context, state) => const MapaAreasPage(),
    ),
    GoRoute(
      path: AppRoutes.medidasAmbientales,
      builder: (context, state) => const MedidasAmbientalesPage(),
    ),
    GoRoute(
      path: AppRoutes.medidaDetalle,
      builder: (context, state) {
        final medidaId = state.uri.queryParameters['id'] ?? '';
        return MedidaDetallePage(medidaId: medidaId);
      },
    ),
    GoRoute(
      path: AppRoutes.equipoMinisterio,
      builder: (context, state) => const EquipoMinisterioPage(),
    ),
    GoRoute(
      path: AppRoutes.voluntariado,
      builder: (context, state) => const VoluntariadoPage(),
    ),
    GoRoute(
      path: AppRoutes.registroVoluntario,
      builder: (context, state) => const RegistroVoluntarioPage(),
    ),
    GoRoute(
      path: AppRoutes.acercaDe,
      builder: (context, state) => const AcercaDePage(),
    ),
      GoRoute(
      path: AppRoutes.reportDamage,
      builder: (context, state) {
        final token = Session.getToken();
        if (token == null || token.isEmpty) {
          return const LoginScreen();
        }
        return ReportDamageScreen(token: token);
      },
    ),

  GoRoute(
    path: AppRoutes.myReports,
    builder: (context, state) {
      final token = Session.getToken();
      if (token == null || token.isEmpty) {
        return const LoginScreen();
      }
      return MyReportsScreen(token: token);
    },
  ),


  ],

);
