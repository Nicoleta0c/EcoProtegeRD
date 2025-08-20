import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/medida_ambiental.dart';
import '../../services/api_service.dart';
import '../../routes/routes.dart';

class MedidasAmbientalesPage extends StatefulWidget {
  const MedidasAmbientalesPage({super.key});

  @override
  State<MedidasAmbientalesPage> createState() => _MedidasAmbientalesPageState();
}

class _MedidasAmbientalesPageState extends State<MedidasAmbientalesPage> {
  List<MedidaAmbiental> medidas = [];
  List<MedidaAmbiental> filteredMedidas = [];
  bool isLoading = true;
  String searchQuery = '';
  String selectedCategory = 'Todas';

  @override
  void initState() {
    super.initState();
    _loadMedidas();
  }

  Future<void> _loadMedidas() async {
    try {
      final loadedMedidas = await ApiService.getMedidasAmbientales();
      setState(() {
        medidas = loadedMedidas;
        filteredMedidas = loadedMedidas;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _filterMedidas() {
    setState(() {
      filteredMedidas = medidas.where((medida) {
        final matchesSearch = searchQuery.isEmpty ||
            medida.titulo.toLowerCase().contains(searchQuery.toLowerCase()) ||
            medida.descripcion.toLowerCase().contains(searchQuery.toLowerCase());
        
        final matchesCategory = selectedCategory == 'Todas' ||
            medida.categoria == selectedCategory;
        
        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  List<String> get categories {
    final cats = ['Todas'];
    cats.addAll(medidas.map((m) => m.categoria).toSet().toList());
    return cats;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medidas Ambientales'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'Buscar medidas ambientales...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    searchQuery = value;
                    _filterMedidas();
                  },
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      final isSelected = selectedCategory == category;
                      
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              selectedCategory = category;
                            });
                            _filterMedidas();
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredMedidas.isEmpty
                    ? const Center(
                        child: Text('No se encontraron medidas ambientales'),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filteredMedidas.length,
                        itemBuilder: (context, index) {
                          final medida = filteredMedidas[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                context.push(
                                  '${AppRoutes.medidaDetalle}?id=${medida.id}',
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary
                                                .withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Icon(
                                            Icons.eco,
                                            color: Theme.of(context).colorScheme.primary,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                medida.titulo,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .secondary
                                                      .withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  medida.categoria,
                                                  style: TextStyle(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .secondary,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Icon(Icons.arrow_forward_ios),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      medida.descripcion,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
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
