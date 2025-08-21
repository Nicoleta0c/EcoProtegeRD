import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../../utils/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_fiel.dart';

class ReportDamageScreen extends StatefulWidget {
  final String token;
  const ReportDamageScreen({Key? key, required this.token}) : super(key: key);

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

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;

    if (_pickedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an image'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final lat = double.tryParse(_latController.text.trim());
    final lon = double.tryParse(_lonController.text.trim());

    if (lat == null || lon == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Latitude and Longitude must be valid numbers'),
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

      if (base64Image.contains(',')) {
        base64Image = base64Image.split(',').last;
      }

      final body = json.encode({
        'titulo': _titleController.text.trim(),
        'descripcion': _descriptionController.text.trim(),
        'foto': base64Image,
        'latitud': lat,
        'longitud': lon,
      });

      print('--- JSON BODY TO SEND ---');
      print(body);
      print('-------------------------');

      final uri = Uri.parse('https://adamix.net/medioambiente/reportes');
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
        body: body,
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      setState(() => _isLoading = false);

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Report created successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        _formKey.currentState!.reset();
        setState(() => _pickedImage = null);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating report: ${response.body}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unexpected error: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Damage'),
        backgroundColor: AppColors.primaryGreen,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomTextField(
                label: 'Title *',
                controller: _titleController,
                validator: (v) => v == null || v.isEmpty ? 'Title is required' : null,
                hint: 'Enter damage title',
                maxLines: 1,
                icon: Icons.title,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Description *',
                controller: _descriptionController,
                validator: (v) => v == null || v.isEmpty ? 'Description is required' : null,
                maxLines: 4,
                hint: 'Describe the damage in detail',
                icon: Icons.description,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Latitude *',
                controller: _latController,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Latitude is required';
                  final value = double.tryParse(v);
                  if (value == null) return 'Must be a valid number';
                  if (value < -90 || value > 90) return 'Must be between -90 and 90';
                  return null;
                },
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                maxLines: 1,
                hint: 'Ej: 18.4861',
                icon: Icons.location_on,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Longitude *',
                controller: _lonController,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Longitude is required';
                  final value = double.tryParse(v);
                  if (value == null) return 'Must be a valid number';
                  if (value < -180 || value > 180) return 'Must be between -180 y 180';
                  return null;
                },
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                maxLines: 1,
                hint: 'Ej: -69.9312',
                icon: Icons.location_on,
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.lightGray,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.mediumGray),
                  ),
                  child: _pickedImage == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.camera_alt, size: 50, color: AppColors.darkGray),
                            const SizedBox(height: 8),
                            Text(
                              'Tap to select image *',
                              style: TextStyle(color: AppColors.darkGray),
                            ),
                          ],
                        )
                      : Image.file(
                          File(_pickedImage!.path),
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '* Required fields',
                style: TextStyle(
                  color: AppColors.darkGray,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 32),
              CustomButton(
                text: 'Submit Report',
                onPressed: _submitReport,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
