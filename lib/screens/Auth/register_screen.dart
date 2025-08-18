import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../utils/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_fiel.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cedulaController = TextEditingController();
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _correoController = TextEditingController();
  final _passwordController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _matriculaController = TextEditingController();
  
  bool _isLoading = false;

  @override
  void dispose() {
    _cedulaController.dispose();
    _nombreController.dispose();
    _apellidoController.dispose();
    _correoController.dispose();
    _passwordController.dispose();
    _telefonoController.dispose();
    _matriculaController.dispose();
    super.dispose();
  }

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName es requerido';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'El correo es requerido';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Ingrese un correo valido';
    }
    return null;
  }

  String? _validateCedula(String? value) {
    if (value == null || value.isEmpty) {
      return 'La cedula es requerida';
    }
    if (value.length != 11) {
      return 'La cedula debe tener 11 digitos';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'La cedula solo debe contener numeros';
    }
    return null;
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await AuthService.register(
        cedula: _cedulaController.text.trim(),
        nombre: _nombreController.text.trim(),
        apellido: _apellidoController.text.trim(),
        correo: _correoController.text.trim(),
        password: _passwordController.text,
        telefono: _telefonoController.text.trim(),
        matricula: _matriculaController.text.trim(),
      );

      print(result); // debug: muestra todo lo que devuelve el backend

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registro exitoso'),
            backgroundColor: AppColors.success,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      } else {
        String errorMessage = 'Error en el registro';
        // Aqui capturamos correctamente el error que viene en data['error']
        if (result.containsKey('data') && result['data'] != null && result['data']['error'] != null) {
          errorMessage = result['data']['error'];
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ocurrio un error: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.eco,
                            size: 50,
                            color: AppColors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'EcoProtegeRD',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkGreen,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    'Crear Cuenta',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGreen,
                    ),
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    label: 'Cedula',
                    hint: 'Ingrese su cedula (11 digitos)',
                    icon: Icons.credit_card,
                    controller: _cedulaController,
                    keyboardType: TextInputType.number,
                    validator: _validateCedula,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          label: 'Nombre',
                          hint: 'Su nombre',
                          icon: Icons.person,
                          controller: _nombreController,
                          validator: (value) => _validateRequired(value, 'El nombre'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: CustomTextField(
                          label: 'Apellido',
                          hint: 'Su apellido',
                          icon: Icons.person_outline,
                          controller: _apellidoController,
                          validator: (value) => _validateRequired(value, 'El apellido'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    label: 'Correo Electronico',
                    hint: 'example@correo.com',
                    icon: Icons.email,
                    controller: _correoController,
                    keyboardType: TextInputType.emailAddress,
                    validator: _validateEmail,
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    label: 'Contrasena',
                    hint: 'Ingrese su contrasena',
                    icon: Icons.lock,
                    controller: _passwordController,
                    isPassword: true,
                    validator: (value) => _validateRequired(value, 'La contrasena'),
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    label: 'Phone',
                    hint: '8095551234',
                    icon: Icons.phone,
                    controller: _telefonoController,
                    keyboardType: TextInputType.phone,
                    validator: (value) => _validateRequired(value, 'Phone requerido'),
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    label: 'Matricula',
                    hint: '2021-0123',
                    icon: Icons.school,
                    controller: _matriculaController,
                    validator: (value) => _validateRequired(value, 'La matricula'),
                  ),
                  const SizedBox(height: 32),
                  CustomButton(
                    text: 'Registrarse',
                    onPressed: _register,
                    isLoading: _isLoading,
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                        );
                      },
                      child: RichText(
                        text: const TextSpan(
                          text: 'Ya tienes cuenta? ',
                          style: TextStyle(color: AppColors.darkGray, fontSize: 16),
                          children: [
                            TextSpan(
                              text: 'Iniciar Sesion',
                              style: TextStyle(
                                color: AppColors.primaryGreen,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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
