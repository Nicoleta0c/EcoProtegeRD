import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../widgets/custom_drawer.dart';

class AboutUsPage extends StatefulWidget {
  const AboutUsPage({super.key});

  @override
  State<AboutUsPage> createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage> {
  Map<String, dynamic>? ministryInfo;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMinistryInfo();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadMinistryInfo() async {
    try {
      final info = await ApiService.getMinistryInfo();
      setState(() {
        ministryInfo = info;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sobre Nosotros'),
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
                        _loadMinistryInfo();
                      },
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Video section temporalmente deshabilitada por problemas de CORS
                    Container(
                      width: double.infinity,
                      height: 200,
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                        border: Border.all(
                          color: const Color(0xFF2E7D32).withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.video_library,
                            size: 48,
                            color: Color(0xFF2E7D32),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Video Institucional',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Próximamente disponible',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    ), // Historia
                    _buildSection(
                      'Historia',
                      ministryInfo?['historia'] ??
                          'El Ministerio de Medio Ambiente y Recursos Naturales de la República Dominicana fue creado para proteger y conservar el medio ambiente, promoviendo el desarrollo sostenible y la gestión responsable de los recursos naturales del país.',
                      Icons.history,
                    ),

                    const SizedBox(height: 24),

                    // Misión
                    _buildSection(
                      'Misión',
                      ministryInfo?['mision'] ??
                          'Formular, normar, aplicar y supervisar las políticas, estrategias y planes destinados a la protección y mejoramiento del medio ambiente y los recursos naturales, garantizando un desarrollo sostenible en beneficio de las presentes y futuras generaciones.',
                      Icons.flag,
                    ),

                    const SizedBox(height: 24),

                    // Visión
                    _buildSection(
                      'Visión',
                      ministryInfo?['vision'] ??
                          'Ser la institución líder en la protección del medio ambiente y la gestión sostenible de los recursos naturales de la República Dominicana, reconocida por su eficiencia, transparencia e innovación en el cumplimiento de su mandato constitucional.',
                      Icons.visibility,
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildSection(String title, String content, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: const Color(0xFF2E7D32), size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
              color: Colors.black87,
            ),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }
}
