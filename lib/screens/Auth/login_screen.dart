import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';
import '../../utils/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_fiel.dart';
import '../../routes/routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _correoController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _correoController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'El correo es requerido';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) return 'Ingrese un correo válido';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'La contraseña es requerida';
    return null;
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final result = await AuthService.login(
        correo: _correoController.text.trim(),
        password: _passwordController.text,
      );

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Inicio de sesión exitoso'),
            backgroundColor: AppColors.success,
          ),
        );
        context.go(AppRoutes.home);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error'] ?? 'Error en el inicio de sesión'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                 // const SizedBox(height: 10),
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [BoxShadow(color: AppColors.primaryGreen.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
                          ),
                          child: const Icon(Icons.eco, size: 60, color: AppColors.white),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'EcoProtegeRD',
                          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.darkGreen),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Text('Iniciar Sesión', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.darkGreen)),
                  const SizedBox(height: 40),
                  CustomTextField(
                    label: 'Correo Electronico',
                    hint: 'example@gmail.com',
                    icon: Icons.email,
                    controller: _correoController,
                    keyboardType: TextInputType.emailAddress,
                    validator: _validateEmail,
                  ),
                  const SizedBox(height: 24),
                  CustomTextField(
                    label: 'Contraseña',
                    hint: 'Ingrese su contraseña',
                    icon: Icons.lock,
                    controller: _passwordController,
                    isPassword: true,
                    validator: _validatePassword,
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: const Text('¿Olvidaste tu contraseña?', style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(height: 32),
                  CustomButton(text: 'Iniciar Sesion', onPressed: _login, isLoading: _isLoading),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(child: Divider(color: AppColors.mediumGray)),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('O', style: TextStyle(color: AppColors.darkGray, fontWeight: FontWeight.w500)),
                      ),
                      Expanded(child: Divider(color: AppColors.mediumGray)),
                    ],
                  ),
                  const SizedBox(height: 32),
                  CustomButton(
                    text: 'Crear Nueva Cuenta',
                    onPressed: () => context.go(AppRoutes.Register),
                    isOutlined: true,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
