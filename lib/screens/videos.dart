import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/video.dart';
import '../services/api_service.dart';
import '../widgets/custom_drawer.dart';

class VideosPage extends StatefulWidget {
  const VideosPage({super.key});

  @override
  State<VideosPage> createState() => _VideosPageState();
}

class _VideosPageState extends State<VideosPage> {
  List<Video> videos = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadVideos();
  }

  Future<void> _loadVideos() async {
    try {
      final loadedVideos = await ApiService.getVideos();
      setState(() {
        videos = loadedVideos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  String _formatearDuracion(String? duracion) {
    if (duracion == null || duracion.isEmpty) return '';

    // Si ya está en formato correcto (HH:MM:SS o MM:SS), lo retornamos
    if (RegExp(r'^\d{1,2}:\d{2}(:\d{2})?$').hasMatch(duracion)) {
      return duracion;
    }

    // Si es un número (segundos), lo convertimos
    try {
      final segundos = int.parse(duracion);
      final horas = segundos ~/ 3600;
      final minutos = (segundos % 3600) ~/ 60;
      final segs = segundos % 60;

      if (horas > 0) {
        return '${horas.toString().padLeft(2, '0')}:${minutos.toString().padLeft(2, '0')}:${segs.toString().padLeft(2, '0')}';
      } else {
        return '${minutos.toString().padLeft(2, '0')}:${segs.toString().padLeft(2, '0')}';
      }
    } catch (e) {
      return duracion;
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
      } else if (difference < 30) {
        final semanas = (difference / 7).floor();
        return 'Hace $semanas ${semanas == 1 ? 'semana' : 'semanas'}';
      } else {
        return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
      }
    } catch (e) {
      return 'Fecha no disponible';
    }
  }

  Future<void> _reproducirVideo(Video video) async {
    if (video.url == null || video.url!.isEmpty) {
      _mostrarError('URL del video no disponible');
      return;
    }

    try {
      final String videoUrl = video.url!;

      // Si es un video de YouTube, abrir en navegador/app de YouTube
      if (videoUrl.contains('youtube.com') || videoUrl.contains('youtu.be')) {
        final Uri url = Uri.parse(videoUrl);

        // Primero intentar abrir con la app de YouTube
        try {
          final bool launched = await launchUrl(
            url,
            mode: LaunchMode.externalNonBrowserApplication,
          );

          if (!launched) {
            // Si no funciona con la app, intentar con el navegador
            await launchUrl(url, mode: LaunchMode.externalApplication);
          }
        } catch (e) {
          // Si ambos fallan, mostrar mensaje con opción de copiar URL
          _mostrarOpcionesYoutube(videoUrl);
        }
      }
      // Para cualquier otro tipo de video, intentar reproductor interno primero
      else {
        _mostrarReproductorInterno(video);
      }
    } catch (e) {
      _mostrarError('Error al reproducir el video: $e');
    }
  }

  void _mostrarOpcionesYoutube(String url) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Abrir Video de YouTube'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('No se pudo abrir automáticamente el video.'),
                const SizedBox(height: 16),
                Text('URL: $url', style: const TextStyle(fontSize: 12)),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  try {
                    await launchUrl(
                      Uri.parse(url),
                      mode: LaunchMode.externalApplication,
                    );
                  } catch (e) {
                    _mostrarError('No se puede abrir el enlace');
                  }
                },
                child: const Text('Abrir en Navegador'),
              ),
            ],
          ),
    );
  }

  void _mostrarReproductorInterno(Video video) {
    showDialog(
      context: context,
      builder: (context) => VideoPlayerDialog(video: video),
    );
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Videos Educativos'),
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
                      'Error al cargar videos',
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
                        _loadVideos();
                      },
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              )
              : videos.isEmpty
              ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.video_library, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('No hay videos disponibles'),
                  ],
                ),
              )
              : RefreshIndicator(
                onRefresh: _loadVideos,
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: videos.length,
                  itemBuilder: (context, index) {
                    final video = videos[index];
                    return _buildVideoCard(video);
                  },
                ),
              ),
    );
  }

  Widget _buildVideoCard(Video video) {
    return GestureDetector(
      onTap: () => _reproducirVideo(video),
      child: Container(
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
            // Thumbnail del video
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      child:
                          video.thumbnail != null && video.thumbnail!.isNotEmpty
                              ? CachedNetworkImage(
                                imageUrl: video.thumbnail!,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                                placeholder:
                                    (context, url) => Container(
                                      color: Colors.grey[200],
                                      child: const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    ),
                                errorWidget:
                                    (context, url, error) => Container(
                                      color: Colors.grey[200],
                                      child: const Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.video_library,
                                            size: 32,
                                            color: Colors.grey,
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            'Sin imagen',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                              )
                              : Container(
                                color: Colors.grey[200],
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.video_library,
                                      size: 32,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Sin imagen',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                    ),

                    // Overlay de reproducción
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.3),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.play_circle_fill,
                            size: 48,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    // Duración
                    if (video.duracion != null && video.duracion!.isNotEmpty)
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _formatearDuracion(video.duracion),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Información del video
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título
                    Text(
                      video.titulo ?? 'Sin título',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),

                    // Descripción
                    if (video.descripcion != null &&
                        video.descripcion!.isNotEmpty)
                      Expanded(
                        child: Text(
                          video.descripcion!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black87,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                    const SizedBox(height: 8),

                    // Categoría y fecha
                    Row(
                      children: [
                        if (video.categoria != null &&
                            video.categoria!.isNotEmpty)
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF2E7D32,
                                ).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                video.categoria!,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF2E7D32),
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    Text(
                      _formatearFecha(video.fechaSubida),
                      style: TextStyle(fontSize: 10, color: Colors.grey[600]),
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

class VideoPlayerDialog extends StatefulWidget {
  final Video video;

  const VideoPlayerDialog({super.key, required this.video});

  @override
  State<VideoPlayerDialog> createState() => _VideoPlayerDialogState();
}

class _VideoPlayerDialogState extends State<VideoPlayerDialog> {
  VideoPlayerController? _controller;
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      if (widget.video.url == null || widget.video.url!.isEmpty) {
        setState(() {
          _hasError = true;
          _errorMessage = 'URL del video no disponible';
          _isLoading = false;
        });
        return;
      }

      // Verificar si la URL es válida
      final Uri videoUri;
      try {
        videoUri = Uri.parse(widget.video.url!);
        if (!videoUri.hasAbsolutePath ||
            (!videoUri.isScheme('http') && !videoUri.isScheme('https'))) {
          throw FormatException('URL inválida');
        }
      } catch (e) {
        setState(() {
          _hasError = true;
          _errorMessage = 'URL del video no es válida';
          _isLoading = false;
        });
        return;
      }

      _controller = VideoPlayerController.networkUrl(videoUri);

      // Agregar timeout para la inicialización
      await _controller!.initialize().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException(
            'Tiempo de espera agotado al cargar el video',
            const Duration(seconds: 30),
          );
        },
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        _controller!.play();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          if (e.toString().contains('NetworkError') ||
              e.toString().contains('HttpException')) {
            _errorMessage =
                'Error de conexión. Verifica tu conexión a Internet.';
          } else if (e.toString().contains('TimeoutException')) {
            _errorMessage =
                'El video tardó demasiado en cargar. Intenta de nuevo.';
          } else if (e.toString().contains('FormatException')) {
            _errorMessage = 'Formato de video no compatible.';
          } else {
            _errorMessage =
                'Error al cargar el video: No se puede reproducir este contenido.';
          }
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    if (_controller != null && _controller!.value.isInitialized) {
      _controller!.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black,
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: Column(
          children: [
            // Header con título y botón cerrar
            Container(
              padding: const EdgeInsets.all(16),
              color: const Color(0xFF2E7D32),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.video.titulo ?? 'Video',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Reproductor de video
            Expanded(
              child:
                  _isLoading
                      ? const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                      : _hasError
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _errorMessage ?? 'Error al cargar el video',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    setState(() {
                                      _isLoading = true;
                                      _hasError = false;
                                      _errorMessage = null;
                                    });
                                    _initializeVideo();
                                  },
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('Reintentar'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2E7D32),
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () async {
                                    if (widget.video.url != null) {
                                      try {
                                        final Uri url = Uri.parse(
                                          widget.video.url!,
                                        );
                                        if (await canLaunchUrl(url)) {
                                          await launchUrl(
                                            url,
                                            mode:
                                                LaunchMode.externalApplication,
                                          );
                                          Navigator.of(context).pop();
                                        }
                                      } catch (e) {
                                        // Error handling
                                      }
                                    }
                                  },
                                  icon: const Icon(Icons.open_in_new),
                                  label: const Text('Abrir en navegador'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                      : _controller != null && _controller!.value.isInitialized
                      ? AspectRatio(
                        aspectRatio: _controller!.value.aspectRatio,
                        child: VideoPlayer(_controller!),
                      )
                      : const Center(
                        child: Text(
                          'Video no disponible',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
            ),

            // Controles de video
            if (!_isLoading &&
                !_hasError &&
                _controller != null &&
                _controller!.value.isInitialized)
              Container(
                padding: const EdgeInsets.all(16),
                color: const Color(0xFF2E7D32),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          if (_controller!.value.isPlaying) {
                            _controller!.pause();
                          } else {
                            _controller!.play();
                          }
                        });
                      },
                      icon: Icon(
                        _controller!.value.isPlaying
                            ? Icons.pause
                            : Icons.play_arrow,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    Expanded(
                      child: VideoProgressIndicator(
                        _controller!,
                        allowScrubbing: true,
                        colors: const VideoProgressColors(
                          playedColor: Colors.white,
                          bufferedColor: Colors.grey,
                          backgroundColor: Colors.grey,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        if (widget.video.url != null) {
                          try {
                            final Uri url = Uri.parse(widget.video.url!);
                            if (await canLaunchUrl(url)) {
                              await launchUrl(
                                url,
                                mode: LaunchMode.externalApplication,
                              );
                            }
                          } catch (e) {
                            // Error handling
                          }
                        }
                      },
                      icon: const Icon(
                        Icons.open_in_new,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
