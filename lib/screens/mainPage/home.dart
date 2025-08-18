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
        'titulo': 'Protege el Medio Ambiente',
        'descripcion':
            'Juntos podemos construir un futuro más verde y sostenible para las próximas generaciones.',
        'imagen':
            'https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?w=800',
      },
      {
        'titulo': 'Conservación de la Biodiversidad',
        'descripcion':
            'Trabajamos para proteger la rica biodiversidad de República Dominicana.',
        'imagen':
            'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=800',
      },
      {
        'titulo': 'Desarrollo Sostenible',
        'descripcion':
            'Promovemos prácticas que equilibren el crecimiento económico con la protección ambiental.',
        'imagen':
            'https://images.unsplash.com/photo-1569163139394-de4e4f43e4e3?w=800',
      },
      {
        'titulo': 'Recursos Naturales',
        'descripcion':
            'Gestionamos responsablemente nuestros recursos naturales para el bienestar de todos.',
        'imagen':
            'https://images.unsplash.com/photo-1518837695005-2083093ee35b?w=800',
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
            height: 250,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 5),
            enlargeCenterPage: true,
            viewportFraction: 0.9,
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
        Row(
          children: [
            Expanded(
              child: _buildNavigationCard(
                title: 'Sobre Nosotros',
                description: 'Conoce nuestra historia',
                icon: Icons.info_outline,
                onTap: () => context.go(AppRoutes.aboutUs),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildNavigationCard(
                title: 'Servicios',
                description: 'Explora nuestros servicios',
                icon: Icons.business_center_outlined,
                onTap: () => context.go(AppRoutes.services),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _buildNavigationCard(
                title: 'Noticias',
                description: 'Noticias ambientales',
                icon: Icons.article_outlined,
                onTap: () => context.go(AppRoutes.noticias),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildNavigationCard(
                title: 'Videos',
                description: 'Videos educativos',
                icon: Icons.play_circle_outline,
                onTap: () => context.go(AppRoutes.videos),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNavigationCard({
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
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
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: const Color(0xFF2E7D32), size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection() {
    return Container(
      width: double.infinity,
      color: const Color(0xFF2E7D32).withValues(alpha: 0.05),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Icon(Icons.eco, size: 48, color: Color(0xFF2E7D32)),
          const SizedBox(height: 16),
          const Text(
            'Ministerio de Medio Ambiente y Recursos Naturales',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Comprometidos con la protección del medio ambiente y el desarrollo sostenible de República Dominicana.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
