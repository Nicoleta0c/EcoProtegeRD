import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/area_protegida.dart';
import '../../services/api_service.dart';
import '../../routes/routes.dart';

class AreasProtegidasPage extends StatefulWidget {
  const AreasProtegidasPage({super.key});

  @override
  State<AreasProtegidasPage> createState() => _AreasProtegidasPageState();
}

class _AreasProtegidasPageState extends State<AreasProtegidasPage> {
  List<AreaProtegida> areas = [];
  List<AreaProtegida> filteredAreas = [];
  bool isLoading = true;
  String searchQuery = '';

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
        filteredAreas = loadedAreas;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _filterAreas(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredAreas = areas;
      } else {
        filteredAreas = areas
            .where((area) =>
                area.nombre.toLowerCase().contains(query.toLowerCase()) ||
                area.ubicacion.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Áreas Protegidas'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: () => context.push(AppRoutes.mapaAreas),
            tooltip: 'Ver en mapa',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Buscar áreas protegidas...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: _filterAreas,
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredAreas.isEmpty
                    ? const Center(
                        child: Text('No se encontraron áreas protegidas'),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredAreas.length,
                        itemBuilder: (context, index) {
                          final area = filteredAreas[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: CircleAvatar(
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                                child: const Icon(
                                  Icons.nature,
                                  color: Colors.white,
                                ),
                              ),
                              title: Text(
                                area.nombre,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 8),
                                  Text(area.descripcion),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.location_on,
                                        size: 16,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          area.ubicacion,
                                          style: const TextStyle(
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (area.categoria != null) ...[
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        area.categoria!,
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios),
                              onTap: () {
                                context.push(
                                  '${AppRoutes.areaDetalle}?id=${area.id}',
                                );
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
