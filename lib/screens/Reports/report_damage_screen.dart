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
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Report Environmental Damage',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        backgroundColor: const Color(0xFF059669),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
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
                      validator: (v) => v == null || v.isEmpty ? 'Title is required' : null,
                      hint: 'Enter a descriptive title',
                      icon: Icons.title_outlined,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 20),
                    
                    _buildEnhancedTextField(
                      label: 'Description',
                      controller: _descriptionController,
                      validator: (v) => v == null || v.isEmpty ? 'Description is required' : null,
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
                                    if (v == null || v.isEmpty) return 'Required';
                                    final value = double.tryParse(v);
                                    if (value == null) return 'Invalid number';
                                    if (value < -90 || value > 90) return 'Range: -90 to 90';
                                    return null;
                                  },
                                  keyboardType: TextInputType.numberWithOptions(decimal: true),
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
                                    if (v == null || v.isEmpty) return 'Required';
                                    final value = double.tryParse(v);
                                    if (value == null) return 'Invalid number';
                                    if (value < -180 || value > 180) return 'Range: -180 to 180';
                                    return null;
                                  },
                                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                                  hint: '-69.9312',
                                  icon: Icons.my_location,
                                  maxLines: 1,
                                  compact: true,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    const Text(
                      'Photo Evidence',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 180,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: _pickedImage == null ? const Color(0xFFF8FAFC) : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _pickedImage == null 
                                ? const Color(0xFF059669).withOpacity(0.3)
                                : const Color(0xFFE2E8F0),
                            width: 2,
                            style: _pickedImage == null ? BorderStyle.solid : BorderStyle.solid,
                          ),
                        ),
                        child: _pickedImage == null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF059669).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(50),
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
                                          color: Colors.black.withOpacity(0.6),
                                          borderRadius: BorderRadius.circular(20),
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
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
                          _isLoading ? 'Submitting Report...' : 'Submit Report',
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
            Icon(
              icon,
              size: 16,
              color: const Color(0xFF059669),
            ),
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
