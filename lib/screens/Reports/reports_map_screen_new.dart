import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:convert';
import '../../utils/app_colors.dart';
import '../../services/api_service.dart';
import '../../widgets/custom_drawer.dart'; // Importamos el Drawer

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
    setState(() => _isLoading = true);
    try {
      final reports = await ApiService.getLocalReports();
      print('DEBUG: Reportes cargados: ${reports.length}');
      setState(() {
        _reports = reports;
        _createMarkers();
        _isLoading = false;
      });
    } catch (e) {
      print('ERROR cargando reportes: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar reportes: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _createMarkers() {
    _markers.clear();

    for (int i = 0; i < _reports.length; i++) {
      final report = _reports[i];
      final lat = report['latitud'];
      final lng = report['longitud'];

      double? latitude;
      double? longitude;

      if (lat is String) latitude = double.tryParse(lat);
      if (lat is num) latitude = lat.toDouble();

      if (lng is String) longitude = double.tryParse(lng);
      if (lng is num) longitude = lng.toDouble();

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

  void _showReportDetails(Map<String, dynamic> report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(report['titulo'] ?? 'Reporte sin título'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (report['foto'] != null && report['foto'].isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.memory(
                    base64Decode(report['foto']),
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
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
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(value)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa de Reportes'),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadReports,
          ),
        ],
      ),
      drawer: const CustomDrawer(), 
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _reports.isEmpty
              ? const Center(child: Text('No hay reportes para mostrar'))
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
    );
  }
}
