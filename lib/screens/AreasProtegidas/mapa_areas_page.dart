import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/area_protegida.dart';
import '../../services/api_service.dart';

class MapaAreasPage extends StatefulWidget {
  const MapaAreasPage({super.key});

  @override
  State<MapaAreasPage> createState() => _MapaAreasPageState();
}

class _MapaAreasPageState extends State<MapaAreasPage> {
  List<AreaProtegida> areas = [];
  bool isLoading = true;
  final MapController _mapController = MapController();
  final List<Marker> _markers = [];

  @override
  void initState() {
    super.initState();
    _loadAreas();
  }

  Future<void> _loadAreas() async {
    try {
      final loadedAreas = await ApiService.getAreasProtegidas();
      setState(() {
        areas = loadedAreas;
        isLoading = false;
      });
      _createMarkers();
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _createMarkers() {
    _markers.clear();
    for (final area in areas) {
      if (area.latitud != null && area.longitud != null) {
        _markers.add(
          Marker(
            point: LatLng(area.latitud!, area.longitud!),
            width: 40,
            height: 40,
            child: GestureDetector(
              onTap: () => _showAreaInfo(area),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.nature, color: Colors.white, size: 24),
              ),
            ),
          ),
        );
      }
    }
    setState(() {});
  }

  void _showAreaInfo(AreaProtegida area) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(area.nombre),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Ubicación: ${area.ubicacion}'),
              const SizedBox(height: 8),
              Text('Descripción: ${area.descripcion}'),
              if (area.categoria != null) ...[
                const SizedBox(height: 8),
                Text('Categoría: ${area.categoria!}'),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _openInExternalMaps(area);
              },
              child: const Text('Ver en Mapa'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openInExternalMaps(AreaProtegida area) async {
    if (area.latitud != null && area.longitud != null) {
      final url =
          'https://www.openstreetmap.org/?mlat=${area.latitud}&mlon=${area.longitud}&zoom=15';
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      }
    }
  }

  Future<void> _openAllAreasInMaps() async {
    final validAreas =
        areas
            .where((area) => area.latitud != null && area.longitud != null)
            .toList();

    if (validAreas.isNotEmpty) {
      // Usar OpenStreetMap para mostrar múltiples puntos
      final centerLat =
          validAreas.map((a) => a.latitud!).reduce((a, b) => a + b) /
          validAreas.length;
      final centerLon =
          validAreas.map((a) => a.longitud!).reduce((a, b) => a + b) /
          validAreas.length;

      final url =
          'https://www.openstreetmap.org/?mlat=$centerLat&mlon=$centerLon&zoom=10';
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      }
    }
  }

  void _centerOnAllAreas() {
    final validAreas =
        areas
            .where((area) => area.latitud != null && area.longitud != null)
            .toList();

    if (validAreas.isNotEmpty) {
      final centerLat =
          validAreas.map((a) => a.latitud!).reduce((a, b) => a + b) /
          validAreas.length;
      final centerLon =
          validAreas.map((a) => a.longitud!).reduce((a, b) => a + b) /
          validAreas.length;

      _mapController.move(LatLng(centerLat, centerLon), 10.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa de Áreas Protegidas'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_new),
            onPressed: _openAllAreasInMaps,
            tooltip: 'Ver en OpenStreetMap',
          ),
          IconButton(
            icon: const Icon(Icons.center_focus_strong),
            onPressed: _centerOnAllAreas,
            tooltip: 'Centrar en todas las áreas',
          ),
        ],
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : areas.isEmpty
              ? const Center(child: Text('No se encontraron áreas protegidas'))
              : Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.1),
                    child: Column(
                      children: [
                        Icon(
                          Icons.map,
                          size: 48,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Mapa Interactivo de Áreas Protegidas',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Encontradas ${areas.where((a) => a.latitud != null && a.longitud != null).length} áreas con coordenadas',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: const LatLng(
                          18.7357,
                          -70.1627,
                        ), // República Dominicana
                        initialZoom: 8.0,
                        minZoom: 3.0,
                        maxZoom: 18.0,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.ecoprotege.app',
                          maxZoom: 18,
                        ),
                        MarkerLayer(markers: _markers),
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    color: Theme.of(context).colorScheme.surface,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _openAllAreasInMaps,
                            icon: const Icon(Icons.open_in_new),
                            label: const Text('Ver en OSM'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _centerOnAllAreas,
                            icon: const Icon(Icons.center_focus_strong),
                            label: const Text('Centrar'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.secondary,
                              foregroundColor: Colors.white,
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
