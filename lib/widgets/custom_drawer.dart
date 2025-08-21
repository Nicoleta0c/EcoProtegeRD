import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../routes/routes.dart';
import '../utils/session.dart';

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
                Row(
                  children: [
                    const Icon(Icons.eco, size: 40, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'EcoProtegeRD',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Ministerio de Medio Ambiente',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Mostrar información del usuario si está logueado
                if (Session.isLoggedIn()) ...[
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          child: Text(
                            Session.getUserName().isNotEmpty
                                ? Session.getUserName()[0].toUpperCase()
                                : 'U',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                Session.getUserName(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                Session.getUserEmail(),
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: 12,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  // Mostrar mensaje para usuarios no logueados
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.person_outline,
                          color: Colors.white70,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Invitado - Inicia sesión',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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
            icon: Icons.login,
            title: 'Login',
            route: AppRoutes.Login,
          ),
          _buildDrawerItem(
            context,
            icon: Icons.app_registration_rounded,
            title: 'Register',
            route: AppRoutes.Register,
          ),
          const Divider(),
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
          const Divider(),
          _buildDrawerItem(
            context,
            icon: Icons.nature,
            title: 'Áreas Protegidas',
            route: AppRoutes.areasProtegidas,
          ),
          _buildDrawerItem(
            context,
            icon: Icons.eco,
            title: 'Medidas Ambientales',
            route: AppRoutes.medidasAmbientales,
          ),
          _buildDrawerItem(
            context,
            icon: Icons.people,
            title: 'Equipo Ministerial',
            route: AppRoutes.equipoMinisterio,
          ),
          _buildDrawerItem(
            context,
            icon: Icons.volunteer_activism,
            title: 'Voluntariado',
            route: AppRoutes.voluntariado,
          ),
          const Divider(),
          _buildDrawerItem(
            context,
            icon: Icons.report_problem,
            title: 'Reportar Daño Ambiental',
            route: AppRoutes.reportDamage,
          ),
          _buildDrawerItem(
            context,
            icon: Icons.assignment,
            title: 'Mis Reportes',
            route: AppRoutes.myReports,
          ),
          _buildDrawerItem(
            context,
            icon: Icons.map,
            title: 'Mapa de Reportes',
            route: AppRoutes.reportsMap,
          ),
          const Divider(),
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
          _buildDrawerItem(
            context,
            icon: Icons.info_outline,
            title: 'Acerca de',
            route: AppRoutes.acercaDe,
          ),
          const Divider(),
          // Opciones de autenticación
          if (!Session.isLoggedIn()) ...[
            _buildDrawerItem(
              context,
              icon: Icons.login,
              title: 'Iniciar Sesión',
              route: AppRoutes.Login,
            ),
            _buildDrawerItem(
              context,
              icon: Icons.person_add,
              title: 'Registrarse',
              route: AppRoutes.Register,
            ),
          ] else ...[
            ListTile(
              leading: const Icon(Icons.logout, color: Color(0xFF2E7D32)),
              title: const Text('Cerrar Sesión'),
              subtitle: Text('Salir como ${Session.getUserName()}'),
              onTap: () {
                _showLogoutDialog(context);
              },
            ),
          ],
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
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cerrar Sesión'),
          content: Text(
            '¿Estás seguro de que quieres cerrar sesión, ${Session.getUserName()}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Cerrar diálogo
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Cerrar diálogo
                Navigator.pop(context); // Cerrar drawer
                Session.logout(); // Cerrar sesión
                context.go(AppRoutes.home); // Ir al home
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
              ),
              child: const Text('Cerrar Sesión'),
            ),
          ],
        );
      },
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
