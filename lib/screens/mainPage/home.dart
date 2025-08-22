import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../services/api_service.dart';
import '../../routes/routes.dart';
import '../../widgets/custom_drawer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> sliderContent = [];
  bool _isLoadingSlider = true;
  int _currentSlideIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadSliderContent();
  }

  Future<void> _loadSliderContent() async {
    try {
      final content = await ApiService.getSliderContent();
      setState(() {
        sliderContent = content;
        _isLoadingSlider = false;
      });
    } catch (e) {
      setState(() {
        sliderContent = _getDefaultSliderContent();
        _isLoadingSlider = false;
      });
    }
  }

  List<Map<String, dynamic>> _getDefaultSliderContent() {
    return [
      {
        'titulo': 'Parques Nacionales de RD',
        'descripcion':
            'Descubre las maravillas naturales protegidas de República Dominicana y su biodiversidad única.',
        'imagen':
            'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=1200&h=600&fit=crop',
      },
      {
        'titulo': 'Conservación Marina',
        'descripcion':
            'Protegemos nuestros arrecifes de coral y ecosistemas marinos del Caribe dominicano.',
        'imagen':
            'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=1200&h=600&fit=crop',
      },
      {
        'titulo': 'Reforestación Nacional',
        'descripcion':
            'Iniciativas de reforestación para recuperar nuestros bosques tropicales y combatir el cambio climático.',
        'imagen':
            'https://images.unsplash.com/photo-1574263867128-a3c4534f0b4c?w=1200&h=600&fit=crop',
      },
      {
        'titulo': 'Energías Renovables',
        'descripcion':
            'Promovemos el uso de energía solar y eólica para un futuro energético sostenible.',
        'imagen':
            'https://images.unsplash.com/photo-1466611653911-95081537e5b7?w=1200&h=600&fit=crop',
      },
      {
        'titulo': 'Biodiversidad Endémica',
        'descripcion':
            'Protegemos las especies únicas de La Española: iguanas, hutías, y aves endémicas.',
        'imagen':
            'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=1200&h=600&fit=crop',
      },
      {
        'titulo': 'Gestión de Residuos',
        'descripcion':
            'Programas de reciclaje y manejo responsable de desechos para ciudades más limpias.',
        'imagen':
            'https://images.unsplash.com/photo-1532996122724-e3c354a0b15b?w=1200&h=600&fit=crop',
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EcoProtegeRD'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      drawer: const CustomDrawer(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             const SizedBox(height: 16),
            // Slider de imágenes
            _buildImageSlider(),

            const SizedBox(height: 24),

            // Sección de navegación rápida
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Explora Nuestros Módulos',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildQuickNavigationCards(),
                ],
              ),
            ),

            const SizedBox(height: 24),

            _buildQuickStats(),

            const SizedBox(height: 24),

            _buildInfoSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSlider() {
    if (_isLoadingSlider) {
      return Container(
        height: 250,
        color: Colors.grey[200],
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (sliderContent.isEmpty) {
      return Container(
        height: 250,
        color: Colors.grey[200],
        child: const Center(child: Text('No hay contenido disponible')),
      );
    }

    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: 280,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 4),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            enlargeCenterPage: true,
            enlargeFactor: 0.2,
            viewportFraction: 0.85,
            onPageChanged: (index, reason) {
              setState(() {
                _currentSlideIndex = index;
              });
            },
          ),
          items:
              sliderContent.map((item) {
                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.symmetric(horizontal: 5.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            CachedNetworkImage(
                              imageUrl: item['imagen'] ?? '',
                              fit: BoxFit.cover,
                              placeholder:
                                  (context, url) => Container(
                                    color: Colors.grey[300],
                                    child: const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                              errorWidget:
                                  (context, url, error) => Container(
                                    color: const Color(0xFF2E7D32),
                                    child: const Icon(
                                      Icons.nature,
                                      size: 64,
                                      color: Colors.white,
                                    ),
                                  ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withValues(alpha: 0.7),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 20,
                              left: 20,
                              right: 20,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['titulo'] ?? '',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    item['descripcion'] ?? '',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children:
              sliderContent.asMap().entries.map((entry) {
                return Container(
                  width: 8.0,
                  height: 8.0,
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        _currentSlideIndex == entry.key
                            ? const Color(0xFF2E7D32)
                            : Colors.grey[300],
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildQuickNavigationCards() {
    return Column(
      children: [
        // Información Institucional
        _buildSectionTitle('Información Institucional'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildNavigationCard(
                title: 'Sobre Nosotros',
                description: 'Misión, visión y valores',
                icon: Icons.info_outline,
                color: const Color(0xFF2E7D32),
                onTap: () => context.go(AppRoutes.aboutUs),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildNavigationCard(
                title: 'Equipo Ministerial',
                description: 'Conoce nuestro equipo',
                icon: Icons.people_outline,
                color: const Color(0xFF2E7D32),
                onTap: () => context.go(AppRoutes.equipoMinisterio),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Servicios y Recursos
        _buildSectionTitle('Servicios y Recursos'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildNavigationCard(
                title: 'Servicios',
                description: 'Trámites y servicios',
                icon: Icons.business_center_outlined,
                color: const Color(0xFF2E7D32),
                onTap: () => context.go(AppRoutes.services),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildNavigationCard(
                title: 'Áreas Protegidas',
                description: 'Parques y reservas',
                icon: Icons.nature_outlined,
                color: const Color(0xFF2E7D32),
                onTap: () => context.go(AppRoutes.areasProtegidas),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildNavigationCard(
                title: 'Medidas Ambientales',
                description: 'Guías de conservación',
                icon: Icons.eco_outlined,
                color: const Color(0xFF2E7D32),
                onTap: () => context.go(AppRoutes.medidasAmbientales),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildNavigationCard(
                title: 'Voluntariado',
                description: 'Únete a la causa',
                icon: Icons.volunteer_activism_outlined,
                color: const Color(0xFF2E7D32),
                onTap: () => context.go(AppRoutes.voluntariado),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Comunicación y Educación
        _buildSectionTitle('Comunicación y Educación'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildNavigationCard(
                title: 'Noticias',
                description: 'Actualidad ambiental',
                icon: Icons.article_outlined,
                color: const Color(0xFF2E7D32),
                onTap: () => context.go(AppRoutes.noticias),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildNavigationCard(
                title: 'Videos',
                description: 'Contenido educativo',
                icon: Icons.play_circle_outline,
                color: const Color(0xFF2E7D32),
                onTap: () => context.go(AppRoutes.videos),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: const Color(0xFF2E7D32),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2E7D32),
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationCard({
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
    Color color = const Color(0xFF2E7D32),
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              description,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xFF2E7D32), const Color(0xFF388E3C)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E7D32).withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Nuestro Impacto',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatCard('150+', 'Áreas Protegidas', Icons.forest),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  '50K+',
                  'Hectáreas Conservadas',
                  Icons.landscape,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  '1000+',
                  'Especies Protegidas',
                  Icons.pets,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  '25+',
                  'Programas Activos',
                  Icons.trending_up,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String number, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 8),
          Text(
            number,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF2E7D32).withValues(alpha: 0.05),
            const Color(0xFF2E7D32).withValues(alpha: 0.1),
          ],
        ),
      ),
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2E7D32).withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.eco, size: 48, color: Colors.white),
          ),
          const SizedBox(height: 24),
          const Text(
            'Ministerio de Medio Ambiente y Recursos Naturales',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Comprometidos con la protección del medio ambiente y el desarrollo sostenible de República Dominicana. Trabajamos cada día para preservar nuestros recursos naturales para las futuras generaciones.',
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[700],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32),
              borderRadius: BorderRadius.circular(25),
            ),
            child: const Text(
              '¡Únete a la misión!',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
