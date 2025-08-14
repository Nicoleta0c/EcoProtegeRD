import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/noticia.dart';
import '../services/api_service.dart';
import '../widgets/custom_drawer.dart';

class NoticiasPage extends StatefulWidget {
  const NoticiasPage({super.key});

  @override
  State<NoticiasPage> createState() => _NoticiasPageState();
}

class _NoticiasPageState extends State<NoticiasPage> {
  List<Noticia> noticias = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadNoticias();
  }

  Future<void> _loadNoticias() async {
    try {
      final loadedNoticias = await ApiService.getNoticias();
      setState(() {
        noticias = loadedNoticias;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  String _formatearFecha(String? fecha) {
    if (fecha == null) return 'Fecha no disponible';
    try {
      final dateTime = DateTime.parse(fecha);
      final now = DateTime.now();
      final difference = now.difference(dateTime).inDays;

      if (difference == 0) {
        return 'Hoy';
      } else if (difference == 1) {
        return 'Ayer';
      } else if (difference < 7) {
        return 'Hace $difference días';
      } else {
        return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
      }
    } catch (e) {
      return 'Fecha no disponible';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Noticias Ambientales'),
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
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red.withValues(alpha: 0.6),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error al cargar noticias',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isLoading = true;
                          _error = null;
                        });
                        _loadNoticias();
                      },
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              )
              : noticias.isEmpty
              ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.article, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('No hay noticias disponibles'),
                  ],
                ),
              )
              : RefreshIndicator(
                onRefresh: _loadNoticias,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: noticias.length,
                  itemBuilder: (context, index) {
                    final noticia = noticias[index];
                    return _buildNoticiaCard(noticia);
                  },
                ),
              ),
    );
  }

  Widget _buildNoticiaCard(Noticia noticia) {
    // Función para obtener una imagen por defecto basada en el contenido de la noticia
    String getDefaultImageForNoticia(String? titulo, String? resumen) {
      final content = '${titulo ?? ''} ${resumen ?? ''}'.toLowerCase();

      if (content.contains('reciclaje') ||
          content.contains('residuo') ||
          content.contains('basura')) {
        return 'https://images.unsplash.com/photo-1532996122724-e3c354a0b15b?w=600';
      } else if (content.contains('agua') ||
          content.contains('mar') ||
          content.contains('oceano')) {
        return 'https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=600';
      } else if (content.contains('bosque') ||
          content.contains('arbol') ||
          content.contains('forestal')) {
        return 'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=600';
      } else if (content.contains('energia') ||
          content.contains('solar') ||
          content.contains('renovable')) {
        return 'https://images.unsplash.com/photo-1466611653911-95081537e5b7?w=600';
      } else if (content.contains('animal') ||
          content.contains('fauna') ||
          content.contains('biodiversidad')) {
        return 'https://images.unsplash.com/photo-1518837695005-2083093ee35b?w=600';
      } else if (content.contains('clima') ||
          content.contains('cambio') ||
          content.contains('calentamiento')) {
        return 'https://images.unsplash.com/photo-1569163139394-de4e4f43e4e3?w=600';
      } else if (content.contains('contaminacion') ||
          content.contains('humo') ||
          content.contains('industrial')) {
        return 'https://images.unsplash.com/photo-1611273426858-450d8e3c9fce?w=600';
      } else {
        return 'https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?w=600';
      }
    }

    // Determinar qué imagen usar
    String imageUrl =
        noticia.imagen != null && noticia.imagen!.isNotEmpty
            ? noticia.imagen!
            : getDefaultImageForNoticia(noticia.titulo, noticia.resumen);

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
          // Imagen de la noticia
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
                        Icon(Icons.article, size: 48, color: Color(0xFF2E7D32)),
                        SizedBox(height: 8),
                        Text(
                          'Noticia Ambiental',
                          style: TextStyle(color: Color(0xFF2E7D32)),
                        ),
                      ],
                    ),
                  ),
            ),
          ),

          // Contenido de la noticia
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Categoría y fecha
                Row(
                  children: [
                    if (noticia.categoria != null &&
                        noticia.categoria!.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          noticia.categoria!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF2E7D32),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    const Spacer(),
                    Text(
                      _formatearFecha(noticia.fechaPublicacion),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Título de la noticia
                Text(
                  noticia.titulo ?? 'Sin título',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),

                const SizedBox(height: 8),

                // Resumen
                if (noticia.resumen != null && noticia.resumen!.isNotEmpty)
                  Text(
                    noticia.resumen!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),

                const SizedBox(height: 12),

                // Autor
                if (noticia.autor != null && noticia.autor!.isNotEmpty)
                  Row(
                    children: [
                      const Icon(Icons.person, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        noticia.autor!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 16),

                // Botón leer más
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _showNoticiaDetalle(noticia);
                    },
                    icon: const Icon(Icons.read_more),
                    label: const Text('Leer más'),
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

  void _showNoticiaDetalle(Noticia noticia) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.8,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Contenido
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Título
                        Text(
                          noticia.titulo ?? 'Sin título',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Metadatos
                        Row(
                          children: [
                            if (noticia.categoria != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF2E7D32,
                                  ).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  noticia.categoria!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF2E7D32),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            const Spacer(),
                            Text(
                              _formatearFecha(noticia.fechaPublicacion),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Imagen
                        if (noticia.imagen != null &&
                            noticia.imagen!.isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedNetworkImage(
                              imageUrl: noticia.imagen!,
                              width: double.infinity,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                          ),

                        const SizedBox(height: 16),

                        // Contenido completo
                        Text(
                          noticia.contenido ??
                              noticia.resumen ??
                              'Contenido no disponible',
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.6,
                            color: Colors.black87,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Autor
                        if (noticia.autor != null && noticia.autor!.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.person,
                                  size: 20,
                                  color: Color(0xFF2E7D32),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Por: ${noticia.autor!}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF2E7D32),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }
}
