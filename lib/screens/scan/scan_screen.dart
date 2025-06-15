import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/fish_detection_provider.dart';
import '../../widgets/custom_appbar.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
    }
  }

  Future<void> _detectFish() async {
    if (_selectedImage == null) return;

    final provider = context.read<FishDetectionProvider>();
    await provider.detectFish(_selectedImage!);

    if (provider.error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${provider.error}')));
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Pilih Sumber Gambar',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F4C75),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildSourceOption(
                      icon: Icons.camera_alt,
                      label: 'Kamera',
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.camera);
                      },
                    ),
                    _buildSourceOption(
                      icon: Icons.photo_library,
                      label: 'Galeri',
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.gallery);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
    );
  }

  Widget _buildSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF3282B8).withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF3282B8).withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 40, color: const Color(0xFF3282B8)),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F4C75),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetectionResults() {
    return Consumer<FishDetectionProvider>(
      builder: (context, provider, child) {
        if (provider.detectionResult == null) return const SizedBox();

        final result = provider.detectionResult!;

        return Container(
          margin: const EdgeInsets.only(top: 20),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3282B8).withOpacity(0.1),
                spreadRadius: 0,
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.analytics_outlined,
                    color: Color(0xFF3282B8),
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Hasil Deteksi',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F4C75),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Annotated Image
              if (result.annotatedImageBase64.isNotEmpty)
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: MemoryImage(
                        base64Decode(result.annotatedImageBase64),
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              // Detection Summary
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF3282B8).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Color(0xFF3282B8),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Ditemukan ${result.totalDetections} jenis ikan',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F4C75),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Detection Details
              if (result.detections.isNotEmpty) ...[
                const Text(
                  'Detail Deteksi:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F4C75),
                  ),
                ),
                const SizedBox(height: 8),
                ...result.detections
                    .map(
                      (detection) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFF3282B8).withOpacity(0.3),
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                detection.className,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF0F4C75),
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getConfidenceColor(
                                  detection.confidence,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${(detection.confidence * 100).toStringAsFixed(1)}%',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ],
            ],
          ),
        );
      },
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return Colors.green;
    if (confidence >= 0.6) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Scan Ikan'),
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F4C75), Color(0xFF3282B8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Deteksi Jenis Ikan',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Ambil foto ikan untuk mengetahui jenisnya',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.camera_alt_outlined,
                    size: 40,
                    color: Colors.white,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Image Preview Section
            if (_selectedImage != null) ...[
              Container(
                width: double.infinity,
                height: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF3282B8).withOpacity(0.1),
                      spreadRadius: 0,
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(_selectedImage!, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _showImageSourceDialog,
                    icon: const Icon(Icons.add_a_photo),
                    label: Text(
                      _selectedImage == null ? 'Pilih Gambar' : 'Ganti Gambar',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3282B8),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                if (_selectedImage != null) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Consumer<FishDetectionProvider>(
                      builder: (context, provider, child) {
                        return ElevatedButton.icon(
                          onPressed: provider.isLoading ? null : _detectFish,
                          icon:
                              provider.isLoading
                                  ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                  : const Icon(Icons.search),
                          label: Text(
                            provider.isLoading ? 'Memproses...' : 'Deteksi',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF06D6A0),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),

            // Detection Results
            _buildDetectionResults(),
          ],
        ),
      ),
    );
  }
}
