import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import '../../utils/app_colors.dart';
import '../../services/api_service.dart';

class ReportDamageScreen extends StatefulWidget {
  const ReportDamageScreen({Key? key}) : super(key: key);

  @override
  State<ReportDamageScreen> createState() => _ReportDamageScreenState();
}

class _ReportDamageScreenState extends State<ReportDamageScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _latController = TextEditingController();
  final _lonController = TextEditingController();
  XFile? _pickedImage;
  bool _isLoading = false;
  bool _isGettingLocation = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _latController.dispose();
    _lonController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 40,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (pickedFile != null) {
        setState(() {
          _pickedImage = pickedFile;
        });
        print('Image selected: ${pickedFile.path}');
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error selecting image'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _getCurrentLocation() async {
    if (!mounted) return;

    setState(() => _isGettingLocation = true);

    try {
      Location location = Location();

      // Verificar si el servicio está habilitado
      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          if (mounted) {
            setState(() => _isGettingLocation = false);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Los servicios de ubicación están deshabilitados. Por favor, habilítalos en la configuración.',
                ),
                backgroundColor: AppColors.error,
                duration: Duration(seconds: 4),
              ),
            );
          }
          return;
        }
      }

      // Verificar permisos
      PermissionStatus permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          if (mounted) {
            setState(() => _isGettingLocation = false);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Permisos de ubicación denegados. Por favor, concede permisos en la configuración.',
                ),
                backgroundColor: AppColors.error,
                duration: Duration(seconds: 4),
              ),
            );
          }
          return;
        }
      }

      // Obtener ubicación con timeout
      LocationData locationData = await location.getLocation().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Timeout obteniendo ubicación');
        },
      );

      // Validar que las coordenadas obtenidas sean válidas
      if (locationData.latitude == null || locationData.longitude == null) {
        throw Exception('No se pudieron obtener las coordenadas');
      }

      if (locationData.latitude == 0.0 || locationData.longitude == 0.0) {
        throw Exception('Las coordenadas obtenidas no son válidas');
      }

      if (mounted) {
        setState(() {
          _latController.text = locationData.latitude!.toStringAsFixed(6);
          _lonController.text = locationData.longitude!.toStringAsFixed(6);
          _isGettingLocation = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ubicación obtenida exitosamente'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error obteniendo ubicación: $e');
      if (mounted) {
        setState(() => _isGettingLocation = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error obteniendo ubicación: ${e.toString()}'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields correctly'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_pickedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an image'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Validar que los campos no estén vacíos
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final latText = _latController.text.trim();
    final lonText = _lonController.text.trim();

    if (title.isEmpty ||
        description.isEmpty ||
        latText.isEmpty ||
        lonText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All fields are required'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final lat = double.tryParse(latText);
    final lon = double.tryParse(lonText);

    if (lat == null || lon == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Latitude and Longitude must be valid numbers'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Validar que las coordenadas no sean 0 (ubicación inválida)
    if (lat == 0.0 || lon == 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Las coordenadas no pueden ser 0. Por favor, obten tu ubicación actual.',
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Validar que las coordenadas estén en un rango válido
    if (lat < -90 || lat > 90 || lon < -180 || lon > 180) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Las coordenadas están fuera del rango válido'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Convertir imagen a base64
      final bytes = await _pickedImage!.readAsBytes();
      String base64Image = base64Encode(bytes);

      print('--- DEBUG REPORT SUBMISSION LOCAL ---');
      print('Title: "$title" (length: ${title.length})');
      print('Description: "$description" (length: ${description.length})');
      print('Latitude: $lat (string: "$latText")');
      print('Longitude: $lon (string: "$lonText")');
      print('Image size: ${base64Image.length} characters');
      print('Guardando reporte localmente...');

      // Usar el ApiService actualizado que ahora guarda localmente
      final result = await ApiService.createReport(
        titulo: title,
        descripcion: description,
        foto: base64Image,
        latitud: lat,
        longitud: lon,
      );

      setState(() => _isLoading = false);

      if (result['success'] == true) {
        // Limpiar formulario
        _titleController.clear();
        _descriptionController.clear();
        _latController.clear();
        _lonController.clear();
        setState(() => _pickedImage = null);

        // Mostrar mensaje de éxito y esperar que se muestre
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('¡Reporte creado exitosamente!'),
              backgroundColor: AppColors.success,
              duration: Duration(seconds: 2),
            ),
          );
        }

        // Esperar a que el SnackBar se muestre y luego navegar
        await Future.delayed(const Duration(milliseconds: 800));

        // Verificar múltiples condiciones antes de navegar
        if (mounted && Navigator.canPop(context) && context.mounted) {
          // Usar pushReplacementNamed en lugar de pop para evitar pantalla negra
          Navigator.pushReplacementNamed(context, '/');
        }
      } else {
        String errorMessage = result['error'] ?? 'Error creating report';
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: AppColors.error,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      print('Unexpected error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error inesperado: $e'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Permitir acceso directo sin autenticación requerida
    return PopScope(
      canPop: !_isLoading, // No permitir retroceso mientras se está cargando
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        // Si no está cargando, permitir salir
        if (!_isLoading && mounted && Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: const Text(
            'Reportar Daño Ambiental',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
          ),
          backgroundColor: const Color(0xFF059669),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              // Verificar si el widget está montado antes de navegar
              if (mounted && Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            },
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF059669).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: const Icon(
                        Icons.report_problem_outlined,
                        size: 32,
                        color: Color(0xFF059669),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Report Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 20),

                      _buildEnhancedTextField(
                        label: 'Title',
                        controller: _titleController,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Title is required';
                          }
                          if (v.trim().length < 3) {
                            return 'Title must be at least 3 characters';
                          }
                          return null;
                        },
                        hint: 'Enter a descriptive title',
                        icon: Icons.title_outlined,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 20),

                      _buildEnhancedTextField(
                        label: 'Description',
                        controller: _descriptionController,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Description is required';
                          }
                          if (v.trim().length < 10) {
                            return 'Description must be at least 10 characters';
                          }
                          return null;
                        },
                        hint: 'Describe the environmental damage in detail',
                        icon: Icons.description_outlined,
                        maxLines: 4,
                      ),
                      const SizedBox(height: 20),

                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  color: const Color(0xFF059669),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Location Coordinates',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1F2937),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildEnhancedTextField(
                                    label: 'Latitude',
                                    controller: _latController,
                                    validator: (v) {
                                      if (v == null || v.trim().isEmpty)
                                        return 'Latitude is required';
                                      final value = double.tryParse(v.trim());
                                      if (value == null)
                                        return 'Invalid number format';
                                      if (value < -90 || value > 90)
                                        return 'Must be between -90 and 90';
                                      if (value == 0.0)
                                        return 'Latitude cannot be 0';
                                      return null;
                                    },
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                          signed: true,
                                        ),
                                    hint: '18.4861',
                                    icon: Icons.my_location,
                                    maxLines: 1,
                                    compact: true,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildEnhancedTextField(
                                    label: 'Longitude',
                                    controller: _lonController,
                                    validator: (v) {
                                      if (v == null || v.trim().isEmpty)
                                        return 'Longitude is required';
                                      final value = double.tryParse(v.trim());
                                      if (value == null)
                                        return 'Invalid number format';
                                      if (value < -180 || value > 180)
                                        return 'Must be between -180 and 180';
                                      if (value == 0.0)
                                        return 'Longitude cannot be 0';
                                      return null;
                                    },
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                          signed: true,
                                        ),
                                    hint: '-69.9312',
                                    icon: Icons.my_location,
                                    maxLines: 1,
                                    compact: true,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed:
                                    _isGettingLocation
                                        ? null
                                        : _getCurrentLocation,
                                icon:
                                    _isGettingLocation
                                        ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Color(0xFF059669),
                                                ),
                                          ),
                                        )
                                        : const Icon(Icons.gps_fixed, size: 18),
                                label: Text(
                                  _isGettingLocation
                                      ? 'Getting Location...'
                                      : 'Get Current Location',
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color(0xFF059669),
                                  elevation: 0,
                                  side: const BorderSide(
                                    color: Color(0xFF059669),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      Row(
                        children: [
                          Icon(
                            Icons.camera_alt_outlined,
                            size: 16,
                            color: const Color(0xFF059669),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Photo Evidence *',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF374151),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          height: 180,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color:
                                _pickedImage == null
                                    ? const Color(0xFFF8FAFC)
                                    : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color:
                                  _pickedImage == null
                                      ? const Color(0xFF059669).withOpacity(0.3)
                                      : const Color(0xFFE2E8F0),
                              width: 2,
                              style:
                                  _pickedImage == null
                                      ? BorderStyle.solid
                                      : BorderStyle.solid,
                            ),
                          ),
                          child:
                              _pickedImage == null
                                  ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: const Color(
                                            0xFF059669,
                                          ).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            50,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.camera_alt_outlined,
                                          size: 32,
                                          color: Color(0xFF059669),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      const Text(
                                        'Tap to add photo',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF059669),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Photo evidence helps us understand the issue better',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  )
                                  : ClipRRect(
                                    borderRadius: BorderRadius.circular(14),
                                    child: Stack(
                                      children: [
                                        Image.file(
                                          File(_pickedImage!.path),
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: double.infinity,
                                        ),
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Colors.black.withOpacity(
                                                0.6,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: const Icon(
                                              Icons.edit,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'All fields marked with * are required',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF059669), Color(0xFF10B981)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF059669).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: _isLoading ? null : _submitReport,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_isLoading)
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          else
                            const Icon(
                              Icons.send_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          const SizedBox(width: 12),
                          Text(
                            _isLoading
                                ? 'Submitting Report...'
                                : 'Submit Report',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedTextField({
    required String label,
    required TextEditingController controller,
    required String? Function(String?) validator,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    bool compact = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: const Color(0xFF059669)),
            const SizedBox(width: 6),
            Text(
              '$label *',
              style: TextStyle(
                fontSize: compact ? 12 : 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF374151),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: TextStyle(
            fontSize: compact ? 14 : 16,
            color: const Color(0xFF1F2937),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.grey[500],
              fontSize: compact ? 14 : 16,
            ),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF059669), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFEF4444)),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: compact ? 12 : 16,
            ),
          ),
        ),
      ],
    );
  }
}
