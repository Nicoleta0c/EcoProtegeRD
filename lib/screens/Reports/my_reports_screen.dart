import 'dart:convert';
import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../services/local_database_service.dart';
import '../../widgets/custom_drawer.dart'; // Asegúrate de importar tu drawer

class MyReportsScreen extends StatefulWidget {
  const MyReportsScreen({Key? key}) : super(key: key);

  @override
  State<MyReportsScreen> createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends State<MyReportsScreen> {
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
      final reports = await LocalDatabaseService.getReportsByUser('Usuario Local');
      setState(() => _reports = reports);
    } catch (e) {
      print('Error cargando reportes: $e');
      setState(() => _reports = []);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Reportes'),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: AppColors.white,
        centerTitle: true,
      ),
      drawer: const CustomDrawer(), // Aquí agregamos el Drawer
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _reports.isEmpty
              ? const Center(child: Text('No tienes reportes'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _reports.length,
                  itemBuilder: (context, index) {
                    final report = _reports[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.darkGray.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (report['foto'] != null && report['foto'].isNotEmpty)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.memory(
                                base64Decode(report['foto']),
                                width: double.infinity,
                                height: 180,
                                fit: BoxFit.cover,
                              ),
                            ),
                          const SizedBox(height: 12),
                          Text(
                            report['titulo'] ?? 'Sin título',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.darkGray,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            report['descripcion'] ?? 'Sin descripción',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.darkGray,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Ubicación: ${report['latitud'] ?? '-'}, ${report['longitud'] ?? '-'}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.mediumGray,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
