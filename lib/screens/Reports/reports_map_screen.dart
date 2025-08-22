import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:convert';
import '../../utils/app_colors.dart';
import '../../services/api_service.dart';
import '../../widgets/custom_drawer.dart'; 

class ReportsMapScreen extends StatefulWidget {
  const ReportsMapScreen({Key? key}) : super(key: key);

  @override
  _ReportsMapScreenState createState() => _ReportsMapScreenState();
}

class _ReportsMapScreenState extends State<ReportsMapScreen> {
  final List<Marker> _markers = [];
  bool _isLoading = true;
  List<Map<String, dynamic>> _reports = [];

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    if (!mounted) return;

    setState(() => _isLoading = true);
    try {
      final reports = await ApiService.getLocalReports();
      print('DEBUG: Reportes cargados: ${reports.length}');

      if (!mounted) return;

      setState(() {
        _reports = reports;
        _isLoading = false;
      });

      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) _createMarkers();
    } catch (e) {
      print('ERROR cargando reportes: $e');
      if (!mounted) return;

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar reportes: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _createMarkers() {
    if (!mounted || _reports.isEmpty) return;

    try {
      _markers.clear();

      for (int i = 0; i < _reports.length; i++) {
        final report = _reports[i];
        final lat = report['latitud'];
        final lng = report['longitud'];

        if (lat != null && lng != null) {
          double? latitude;
          double? longitude;

          if (lat is String) latitude = double.tryParse(lat);
          else if (lat is num) latitude = lat.toDouble();

          if (lng is String) longitude = double.tryParse(lng);
          else if (lng is num) longitude = lng.toDouble();

          if (latitude != null && longitude != null) {
            _markers.add(
              Marker(
                point: LatLng(latitude, longitude),
                child: GestureDetector(
                  onTap: () => _showReportDetails(report),
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.red,
                    size: 40,
                  ),
                ),
              ),
            );
          }
        }
      }

      if (mounted) setState(() {});
    } catch (e) {
      print('ERROR creando marcadores: $e');
    }
  }

  void _showReportDetails(Map<String, dynamic> report) {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(report['titulo'] ?? 'Reporte sin título'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (report['foto'] != null && report['foto'].toString().isNotEmpty)
                _buildReportImage(report['foto']),
              const SizedBox(height: 16),
              _buildDetailRow('Descripción:', report['descripcion'] ?? 'No disponible'),
              const SizedBox(height: 8),
              _buildDetailRow('Latitud:', report['latitud']?.toString() ?? 'No disponible'),
              const SizedBox(height: 8),
              _buildDetailRow('Longitud:', report['longitud']?.toString() ?? 'No disponible'),
              const SizedBox(height: 8),
              _buildDetailRow('Fecha:', report['fecha_creacion'] ?? 'No disponible'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (mounted && Navigator.canPop(context)) Navigator.pop(context);
            },
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildReportImage(String base64Image) {
    try {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.memory(
          base64Decode(base64Image),
          width: double.infinity,
          height: 200,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(8)),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.broken_image, size: 50, color: Colors.grey),
                  SizedBox(height: 8),
                  Text('Error al cargar imagen', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          },
        ),
      );
    } catch (e) {
      return Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(8)),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.broken_image, size: 50, color: Colors.grey),
            SizedBox(height: 8),
            Text('Imagen no disponible', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 80, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
        const SizedBox(width: 8),
        Expanded(child: Text(value)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop && mounted) {
          if (Navigator.canPop(context)) Navigator.pop(context);
          else Navigator.pushReplacementNamed(context, '/');
        }
      },
      child: Scaffold(
        drawer: const CustomDrawer(), // <-- Menú lateral agregado
        appBar: AppBar(
          title: const Text('Mapa de Reportes'),
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: Colors.white,
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _loadReports)],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _reports.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.map_outlined, size: 80, color: Colors.grey.shade400),
                        const SizedBox(height: 24),
                        Text('No hay reportes para mostrar',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
                        const SizedBox(height: 8),
                        Text('Crea un reporte para verlo en el mapa',
                            style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(context, '/reports/create').then((_) => _loadReports());
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Crear Reporte'),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryGreen, foregroundColor: Colors.white),
                        ),
                      ],
                    ),
                  )
                : FlutterMap(
                    options: const MapOptions(
                      initialCenter: LatLng(18.735693, -70.162651),
                      initialZoom: 8,
                      minZoom: 3,
                      maxZoom: 18,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.medioambienterd',
                        maxNativeZoom: 19,
                      ),
                      MarkerLayer(markers: _markers),
                    ],
                  ),
      ),
    );
  }
}
