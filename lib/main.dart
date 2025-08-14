import 'package:flutter/material.dart';
import 'routes/app_router.dart';

void main() {
  runApp(const EcoProtegeRDApp());
}

class EcoProtegeRDApp extends StatelessWidget {
  const EcoProtegeRDApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'EcoProtegeRD',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E7D32)),
        useMaterial3: true,
      ),
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
