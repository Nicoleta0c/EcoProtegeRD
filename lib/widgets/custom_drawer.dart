import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../routes/routes.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.eco, size: 48, color: Colors.white),
                const SizedBox(height: 8),
                const Text(
                  'EcoProtegeRD',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Ministerio de Medio Ambiente',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.home,
            title: 'Inicio',
            route: AppRoutes.home,
          ),
          _buildDrawerItem(
            context,
            icon: Icons.info,
            title: 'Sobre Nosotros',
            route: AppRoutes.aboutUs,
          ),
          _buildDrawerItem(
            context,
            icon: Icons.business_center,
            title: 'Servicios',
            route: AppRoutes.services,
          ),
          _buildDrawerItem(
            context,
            icon: Icons.article,
            title: 'Noticias Ambientales',
            route: AppRoutes.noticias,
          ),
          _buildDrawerItem(
            context,
            icon: Icons.video_library,
            title: 'Videos Educativos',
            route: AppRoutes.videos,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.phone, color: Color(0xFF2E7D32)),
            title: const Text('Contacto'),
            subtitle: const Text('809-567-4300'),
            onTap: () {
              // Aquí podrías agregar funcionalidad para llamar
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.language, color: Color(0xFF2E7D32)),
            title: const Text('Sitio Web'),
            subtitle: const Text('medioambiente.gob.do'),
            onTap: () {
              // Aquí podrías agregar funcionalidad para abrir el sitio web
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String route,
  }) {
    final isCurrentRoute = GoRouterState.of(context).uri.path == route;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color:
            isCurrentRoute
                ? const Color(0xFF2E7D32).withValues(alpha: 0.1)
                : null,
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isCurrentRoute ? const Color(0xFF2E7D32) : Colors.grey[600],
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isCurrentRoute ? const Color(0xFF2E7D32) : Colors.black87,
            fontWeight: isCurrentRoute ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: () {
          Navigator.pop(context);
          if (!isCurrentRoute) {
            context.go(route);
          }
        },
      ),
    );
  }
}
