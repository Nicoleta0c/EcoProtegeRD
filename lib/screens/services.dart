import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/service.dart';
import '../services/api_service.dart';
import '../widgets/custom_drawer.dart';

class ServicesPage extends StatefulWidget {
  const ServicesPage({super.key});

  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  List<Service> services = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    try {
      final loadedServices = await ApiService.getServices();
      setState(() {
        services = loadedServices;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _launchUrl(String? url) async {
    if (url == null || url.isEmpty) return;

    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al abrir enlace: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Servicios'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      drawer: const CustomDrawer(),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(_error!, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isLoading = true;
                          _error = null;
                        });
                        _loadServices();
                      },
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              )
              : services.isEmpty
              ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inbox, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('No hay servicios disponibles'),
                  ],
                ),
              )
              : RefreshIndicator(
                onRefresh: _loadServices,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: services.length,
                  itemBuilder: (context, index) {
                    final service = services[index];
                    return _buildServiceCard(service);
                  },
                ),
              ),
    );
  }

  Widget _buildServiceCard(Service service) {
    // Función para obtener una imagen por defecto basada en el nombre del servicio
    String _getDefaultImageForService(String? serviceName) {
      if (serviceName == null)
        return 'https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?w=600';

      final name = serviceName.toLowerCase();

      if (name.contains('reciclaje') || name.contains('residuo')) {
        return 'https://images.unsplash.com/photo-1532996122724-e3c354a0b15b?w=600';
      } else if (name.contains('agua') || name.contains('hidrico')) {
        return 'https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=600';
      } else if (name.contains('bosque') || name.contains('forestal')) {
        return 'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=600';
      } else if (name.contains('energia') || name.contains('renovable')) {
        return 'https://images.unsplash.com/photo-1466611653911-95081537e5b7?w=600';
      } else if (name.contains('educacion') || name.contains('ambiental')) {
        return 'https://images.unsplash.com/photo-1569163139394-de4e4f43e4e3?w=600';
      } else if (name.contains('biodiversidad') || name.contains('vida')) {
        return 'https://images.unsplash.com/photo-1518837695005-2083093ee35b?w=600';
      } else if (name.contains('clima') || name.contains('cambio')) {
        return 'https://images.unsplash.com/photo-1569163139394-de4e4f43e4e3?w=600';
      } else {
        return 'https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?w=600';
      }
    }

    // Determinar qué imagen usar
    String imageUrl =
        service.imagen != null && service.imagen!.isNotEmpty
            ? service.imagen!
            : _getDefaultImageForService(service.nombre);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
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
          // Imagen del servicio
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder:
                  (context, url) => Container(
                    height: 200,
                    color: Colors.grey[200],
                    child: const Center(child: CircularProgressIndicator()),
                  ),
              errorWidget:
                  (context, url, error) => Container(
                    height: 200,
                    color: Colors.grey[200],
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.eco, size: 48, color: Color(0xFF2E7D32)),
                        SizedBox(height: 8),
                        Text(
                          'Servicio Ambiental',
                          style: TextStyle(color: Color(0xFF2E7D32)),
                        ),
                      ],
                    ),
                  ),
            ),
          ),

          // Contenido del servicio
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nombre del servicio
                Text(
                  service.nombre ?? 'Sin nombre',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),

                const SizedBox(height: 8),

                // Descripción
                if (service.descripcion != null &&
                    service.descripcion!.isNotEmpty)
                  Text(
                    service.descripcion!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.justify,
                  ),

                const SizedBox(height: 16),

                // Botón de acción
                if (service.url != null && service.url!.isNotEmpty)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _launchUrl(service.url),
                      icon: const Icon(Icons.open_in_new),
                      label: const Text('Más información'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
