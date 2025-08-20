import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/voluntario.dart';
import '../../services/api_service.dart';
import '../../widgets/custom_text_fiel.dart';
import '../../widgets/custom_button.dart';

class RegistroVoluntarioPage extends StatefulWidget {
  const RegistroVoluntarioPage({super.key});

  @override
  State<RegistroVoluntarioPage> createState() => _RegistroVoluntarioPageState();
}

class _RegistroVoluntarioPageState extends State<RegistroVoluntarioPage> {
  final _formKey = GlobalKey<FormState>();
  final _cedulaController = TextEditingController();
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _telefonoController = TextEditingController();
  
  bool _isLoading = false;

  @override
  void dispose() {
    _cedulaController.dispose();
    _nombreController.dispose();
    _apellidoController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  String? _validateCedula(String? value) {
    if (value == null || value.isEmpty) {
      return 'La cédula es requerida';
    }
    if (value.length < 11) {
      return 'La cédula debe tener al menos 11 dígitos';
    }
    return null;
  }

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName es requerido';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'El correo electrónico es requerido';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Ingrese un correo electrónico válido';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es requerida';
    }
    if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Confirme su contraseña';
    }
    if (value != _passwordController.text) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'El teléfono es requerido';
    }
    if (value.length < 10) {
      return 'El teléfono debe tener al menos 10 dígitos';
    }
    return null;
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final voluntario = Voluntario(
        cedula: _cedulaController.text.trim(),
        nombre: _nombreController.text.trim(),
        apellido: _apellidoController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        telefono: _telefonoController.text.trim(),
      );

      final result = await ApiService.registrarVoluntario(voluntario);

      if (mounted) {
        if (result['success']) {
          _showSuccessDialog(result['message']);
        } else {
          _showErrorDialog(result['message']);
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Error inesperado. Intente nuevamente.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          icon: const Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 48,
          ),
          title: const Text('¡Registro exitoso!'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.pop(); // Return to previous page
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          icon: const Icon(
            Icons.error,
            color: Colors.red,
            size: 48,
          ),
          title: const Text('Error en el registro'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de Voluntario'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Card(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.volunteer_activism,
                        size: 48,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Únete a nuestro equipo',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Completa el formulario para registrarte como voluntario',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Form fields
              CustomTextField(
                controller: _cedulaController,
                label: 'Cédula',
                hint: 'Ingrese su número de cédula',
                keyboardType: TextInputType.number,
                validator: _validateCedula,
                icon: Icons.credit_card,
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _nombreController,
                      label: 'Nombre',
                      hint: 'Ingrese su nombre',
                      validator: (value) => _validateRequired(value, 'El nombre'),
                      icon: Icons.person,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      controller: _apellidoController,
                      label: 'Apellido',
                      hint: 'Ingrese su apellido',
                      validator: (value) => _validateRequired(value, 'El apellido'),
                      icon: Icons.person_outline,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _emailController,
                label: 'Correo electrónico',
                hint: 'Ingrese su correo electrónico',
                keyboardType: TextInputType.emailAddress,
                validator: _validateEmail,
                icon: Icons.email,
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _passwordController,
                label: 'Contraseña',
                hint: 'Ingrese su contraseña',
                isPassword: true,
                validator: _validatePassword,
                icon: Icons.lock,
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _confirmPasswordController,
                label: 'Confirmar contraseña',
                hint: 'Confirme su contraseña',
                isPassword: true,
                validator: _validateConfirmPassword,
                icon: Icons.lock_outline,
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _telefonoController,
                label: 'Teléfono',
                hint: 'Ingrese su número de teléfono',
                keyboardType: TextInputType.phone,
                validator: _validatePhone,
                icon: Icons.phone,
              ),
              const SizedBox(height: 32),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: _isLoading ? 'Registrando...' : 'Registrarse como voluntario',
                  onPressed: _isLoading ? () {} : _submitForm,
                ),
              ),

              const SizedBox(height: 16),

              // Terms and conditions note
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Al registrarte aceptas participar en actividades de voluntariado ambiental y recibirás información sobre nuestros programas.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
