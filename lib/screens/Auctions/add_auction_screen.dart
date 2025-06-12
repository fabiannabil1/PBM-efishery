import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/auction_service.dart';
import '../../services/location_service.dart';
import '../../routes/app_routes.dart';
import '../../widgets/custom_appbar.dart';

class AddAuctionScreen extends StatefulWidget {
  const AddAuctionScreen({super.key});

  @override
  State<AddAuctionScreen> createState() => _AddAuctionScreenState();
}

class _AddAuctionScreenState extends State<AddAuctionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _locationIdController = TextEditingController();
  String? _selectedLocationAddress;
  final _deadlineController = TextEditingController();

  File? _image;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  // Blue theme colors
  static const Color primaryBlue = Color(0xFF1E88E5);
  static const Color lightBlue = Color(0xFF42A5F5);
  static const Color darkBlue = Color(0xFF1565C0);
  static const Color accentBlue = Color(0xFF0D47A1);
  static const Color backgroundBlue = Color(0xFFF3F8FF);

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _locationIdController.dispose();
    _deadlineController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final ImageSource? source = await _showImageSourceDialog();
      if (source == null) return;

      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      }
    } catch (e) {
      _showErrorSnackBar('Gagal memilih gambar: ${e.toString()}');
    }
  }

  Future<ImageSource?> _showImageSourceDialog() async {
    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            color: Colors.white,
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 12, bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Text(
                  'Pilih Sumber Gambar',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: darkBlue,
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.camera_alt, color: primaryBlue),
                  ),
                  title: const Text(
                    'Kamera',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text('Ambil foto langsung'),
                  onTap: () => Navigator.of(context).pop(ImageSource.camera),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.photo_library, color: primaryBlue),
                  ),
                  title: const Text(
                    'Galeri',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text('Pilih dari galeri'),
                  onTap: () => Navigator.of(context).pop(ImageSource.gallery),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _selectDeadline() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: primaryBlue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (!mounted) return;

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: primaryBlue,
                onPrimary: Colors.white,
                surface: Colors.white,
                onSurface: Colors.black,
              ),
            ),
            child: child!,
          );
        },
      );

      if (!mounted) return;

      if (pickedTime != null) {
        final DateTime finalDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        setState(() {
          _deadlineController.text = finalDateTime.toIso8601String();
        });
      }
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_image == null) {
      _showErrorSnackBar('Gambar harus dipilih');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await AuctionService().createAuction(
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        locationId: int.parse(_locationIdController.text),
        startingPrice: double.parse(_priceController.text),
        deadline: _deadlineController.text,
        image: _image!,
      );

      if (!mounted) return;

      if (success) {
        _showSuccessSnackBar('Lelang berhasil ditambahkan');
        Navigator.pop(context, true);
      } else {
        throw Exception('Gagal menambahkan item lelang');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Error: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: primaryBlue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  String? _validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Judul tidak boleh kosong';
    }
    if (value.trim().length < 3) {
      return 'Judul minimal 3 karakter';
    }
    if (value.trim().length > 100) {
      return 'Judul maksimal 100 karakter';
    }
    return null;
  }

  String? _validateDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Deskripsi tidak boleh kosong';
    }
    if (value.trim().length < 10) {
      return 'Deskripsi minimal 10 karakter';
    }
    return null;
  }

  String? _validatePrice(String? value) {
    if (value == null || value.isEmpty) {
      return 'Harga awal tidak boleh kosong';
    }
    final double? price = double.tryParse(value);
    if (price == null) {
      return 'Format harga tidak valid';
    }
    if (price <= 0) {
      return 'Harga harus lebih dari 0';
    }
    if (price > 999999999) {
      return 'Harga terlalu besar';
    }
    return null;
  }

  String? _validateLocationId(String? value) {
    if (value == null || value.isEmpty) {
      return 'ID Lokasi tidak boleh kosong';
    }
    final int? locationId = int.tryParse(value);
    if (locationId == null) {
      return 'ID Lokasi harus berupa angka';
    }
    if (locationId <= 0) {
      return 'ID Lokasi harus lebih dari 0';
    }
    return null;
  }

  String? _validateDeadline(String? value) {
    if (value == null || value.isEmpty) {
      return 'Deadline tidak boleh kosong';
    }
    try {
      final DateTime deadline = DateTime.parse(value);
      if (deadline.isBefore(DateTime.now())) {
        return 'Deadline harus di masa depan';
      }
      return null;
    } catch (e) {
      return 'Format deadline tidak valid';
    }
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    String? hint,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int? maxLines,
    TextCapitalization? textCapitalization,
    bool readOnly = false,
    VoidCallback? onTap,
    Widget? suffixIcon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: primaryBlue, size: 20),
          ),
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: primaryBlue, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey[50],
          labelStyle: const TextStyle(color: Colors.grey),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
        validator: validator,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        maxLines: maxLines ?? 1,
        textCapitalization: textCapitalization ?? TextCapitalization.none,
        readOnly: readOnly,
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundBlue,
      appBar: const CustomAppBar(title: 'Buat Lelang', showBackButton: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Section
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryBlue, lightBlue],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: primaryBlue.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.gavel, size: 48, color: Colors.white),
                      const SizedBox(height: 12),
                      Text(
                        'Buat Lelang Baru',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Isi informasi produk yang akan dilelang',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Information Form Card
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: primaryBlue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.info_outline,
                                color: primaryBlue,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              'Informasi Lelang',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: darkBlue,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        _buildFormField(
                          controller: _titleController,
                          label: 'Judul Lelang',
                          icon: Icons.title,
                          hint: 'Masukkan judul lelang',
                          validator: _validateTitle,
                          textCapitalization: TextCapitalization.words,
                        ),

                        _buildFormField(
                          controller: _descController,
                          label: 'Deskripsi',
                          icon: Icons.description,
                          hint: 'Deskripsikan item yang akan dilelang',
                          validator: _validateDescription,
                          maxLines: 3,
                          textCapitalization: TextCapitalization.sentences,
                        ),

                        _buildFormField(
                          controller: _priceController,
                          label: 'Harga Awal (Rp)',
                          icon: Icons.monetization_on,
                          hint: 'Contoh: 100000',
                          validator: _validatePrice,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        ),

                        // Location Picker
                        Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          child: InkWell(
                            onTap: () async {
                              final result =
                                  await Navigator.pushNamed(
                                        context,
                                        AppRoutes.locationPicker,
                                      )
                                      as Map<String, dynamic>?;

                              if (result != null) {
                                final locationService = LocationService();
                                try {
                                  final locationId = await locationService
                                      .saveLocation(
                                        name: "Lokasi Lelang",
                                        latitude: result['latitude'],
                                        longitude: result['longitude'],
                                        detailAddress: result['address'],
                                      );

                                  if (locationId != null) {
                                    setState(() {
                                      _locationIdController.text =
                                          locationId.toString();
                                      _selectedLocationAddress =
                                          result['address'];
                                    });
                                  }
                                } catch (e) {
                                  _showErrorSnackBar(
                                    'Gagal menyimpan lokasi: $e',
                                  );
                                }
                              }
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color:
                                      _validateLocationId(
                                                _locationIdController.text,
                                              ) !=
                                              null
                                          ? Colors.red
                                          : Colors.grey[300]!,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                color: Colors.grey[50],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(right: 16),
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: primaryBlue.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.location_on,
                                      color: primaryBlue,
                                      size: 20,
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Lokasi',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _selectedLocationAddress ??
                                              'Pilih lokasi di peta',
                                          style: TextStyle(
                                            color:
                                                _selectedLocationAddress == null
                                                    ? Colors.grey
                                                    : Colors.black87,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(Icons.map, color: primaryBlue),
                                ],
                              ),
                            ),
                          ),
                        ),

                        _buildFormField(
                          controller: _deadlineController,
                          label: 'Deadline',
                          icon: Icons.schedule,
                          hint: 'Pilih tanggal dan waktu deadline',
                          validator: _validateDeadline,
                          readOnly: true,
                          onTap: _selectDeadline,
                          suffixIcon: Icon(
                            Icons.calendar_today,
                            color: primaryBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Image Upload Card
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: primaryBlue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.photo_camera,
                                color: primaryBlue,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              'Gambar Produk',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: darkBlue,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        if (_image != null) ...[
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.file(
                                _image!,
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],

                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: OutlinedButton.icon(
                            onPressed: _pickImage,
                            icon: Icon(
                              _image == null
                                  ? Icons.add_photo_alternate
                                  : Icons.edit,
                              color: primaryBlue,
                            ),
                            label: Text(
                              _image == null ? 'Pilih Gambar' : 'Ganti Gambar',
                              style: TextStyle(
                                color: primaryBlue,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: primaryBlue, width: 2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              backgroundColor: primaryBlue.withOpacity(0.05),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Submit Button
                Container(
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryBlue, lightBlue],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: primaryBlue.withOpacity(0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child:
                        _isLoading
                            ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                            : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.gavel, color: Colors.white),
                                const SizedBox(width: 12),
                                Text(
                                  'Buat Lelang',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
