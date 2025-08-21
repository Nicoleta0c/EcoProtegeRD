import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/equipo_ministerio.dart';
import '../../services/api_service.dart';
import '../../widgets/custom_drawer.dart';

class EquipoMinisterioPage extends StatefulWidget {
  const EquipoMinisterioPage({super.key});

  @override
  State<EquipoMinisterioPage> createState() => _EquipoMinisterioPageState();
}

class _EquipoMinisterioPageState extends State<EquipoMinisterioPage> {
  List<EquipoMinisterio> equipo = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEquipo();
  }

  Future<void> _loadEquipo() async {
    try {
      final loadedEquipo = await ApiService.getEquipoMinisterio();
      setState(() {
        equipo = loadedEquipo;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  Future<void> _sendEmail(String email) async {
    final Uri launchUri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(),
      appBar: AppBar(
        title: const Text(
          'Equipo del Ministerio',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : equipo.isEmpty
              ? const Center(
                child: Text('No se encontró información del equipo'),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: equipo.length,
                itemBuilder: (context, index) {
                  final miembro = equipo[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 40,
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.primary.withOpacity(0.1),
                                backgroundImage:
                                    miembro.foto != null
                                        ? NetworkImage(miembro.foto!)
                                        : null,
                                child:
                                    miembro.foto == null
                                        ? Icon(
                                          Icons.person,
                                          size: 40,
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                        )
                                        : null,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${miembro.nombre} ${miembro.apellido}',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      miembro.cargo,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                        fontWeight: FontWeight.w500,
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
                                        miembro.departamento,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.secondary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              if (miembro.telefono != null) ...[
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed:
                                        () => _makePhoneCall(miembro.telefono!),
                                    icon: const Icon(Icons.phone, size: 18),
                                    label: const Text('Llamar'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                              ],
                              if (miembro.email != null) ...[
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () => _sendEmail(miembro.email!),
                                    icon: const Icon(Icons.email, size: 18),
                                    label: const Text('Email'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          if (miembro.telefono != null ||
                              miembro.email != null) ...[
                            const SizedBox(height: 12),
                            const Divider(),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                if (miembro.telefono != null) ...[
                                  const Icon(
                                    Icons.phone,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    miembro.telefono!,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                  if (miembro.email != null) ...[
                                    const SizedBox(width: 16),
                                  ],
                                ],
                                if (miembro.email != null) ...[
                                  const Icon(
                                    Icons.email,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      miembro.email!,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
