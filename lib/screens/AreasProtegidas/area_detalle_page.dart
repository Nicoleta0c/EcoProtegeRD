import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/area_protegida.dart';
import '../../services/api_service.dart';
import '../../widgets/custom_drawer.dart';

class AreaDetallePage extends StatefulWidget {
  final String areaId;

  const AreaDetallePage({super.key, required this.areaId});

  @override
  State<AreaDetallePage> createState() => _AreaDetallePageState();
}

class _AreaDetallePageState extends State<AreaDetallePage> {
  AreaProtegida? area;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadArea();
  }

  Future<void> _loadArea() async {
    try {
      final areas = await ApiService.getAreasProtegidas();
      final foundArea = areas.firstWhere(
        (a) => a.id == widget.areaId,
        orElse: () => areas.first,
      );
      setState(() {
        area = foundArea;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _openInMaps() async {
    if (area?.latitud != null && area?.longitud != null) {
      final url =
          'https://www.google.com/maps?q=${area!.latitud},${area!.longitud}';
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Cargando...'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (area == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: const Center(
          child: Text('No se pudo cargar la información del área'),
        ),
      );
    }

    return Scaffold(
      drawer: const CustomDrawer(),
      appBar: AppBar(
        title: Text(
          area!.nombre,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (area!.latitud != null && area!.longitud != null)
            IconButton(
              icon: const Icon(Icons.map),
              onPressed: _openInMaps,
              tooltip: 'Ver en mapa',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (area!.imagen != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  area!.imagen!,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.nature,
                        size: 64,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],

            Text(
              area!.nombre,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            _buildInfoCard('Descripción', area!.descripcion, Icons.description),
            const SizedBox(height: 16),

            _buildInfoCard('Ubicación', area!.ubicacion, Icons.location_on),
            const SizedBox(height: 16),

            if (area!.categoria != null) ...[
              _buildInfoCard('Categoría', area!.categoria!, Icons.category),
              const SizedBox(height: 16),
            ],

            if (area!.tamano != null) ...[
              _buildInfoCard('Tamaño', area!.tamano!, Icons.straighten),
              const SizedBox(height: 16),
            ],

            if (area!.latitud != null && area!.longitud != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.gps_fixed,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Coordenadas',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Latitud: ${area!.latitud}'),
                      Text('Longitud: ${area!.longitud}'),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: _openInMaps,
                        icon: const Icon(Icons.map),
                        label: const Text('Ver en Google Maps'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String content, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(content),
          ],
        ),
      ),
    );
  }
}
