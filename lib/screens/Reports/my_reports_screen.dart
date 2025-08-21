import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../utils/app_colors.dart';

class MyReportsScreen extends StatefulWidget {
  final String token;
  const MyReportsScreen({Key? key, required this.token}) : super(key: key);

  @override
  State<MyReportsScreen> createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends State<MyReportsScreen> {
  late Future<List<Map<String, dynamic>>> _reportsFuture;

  @override
  void initState() {
    super.initState();
    _reportsFuture = ApiService.getReports(widget.token);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Reports'), backgroundColor: AppColors.primaryGreen),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _reportsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No reports found'));
          }

          final reports = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final report = reports[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  title: Text(report['titulo'] ?? ''),
                  subtitle: Text('Status: ${report['estado'] ?? 'Unknown'}\n${report['fecha'] ?? ''}'),
                  onTap: () => showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text(report['titulo'] ?? ''),
                      content: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Code: ${report['codigo'] ?? ''}'),
                            Text('Date: ${report['fecha'] ?? ''}'),
                            const SizedBox(height: 8),
                            Text('Description: ${report['descripcion'] ?? ''}'),
                            const SizedBox(height: 8),
                            report['foto'] != null
                                ? Image.network(report['foto'])
                                : const SizedBox(),
                            const SizedBox(height: 8),
                            Text('Status: ${report['estado'] ?? ''}'),
                            Text('Ministry Comment: ${report['comentario_ministerio'] ?? ''}'),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
