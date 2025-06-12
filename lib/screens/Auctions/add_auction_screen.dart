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
      // Tampilkan dialog pilihan sumber gambar
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Kamera'),
                onTap: () {
                  Navigator.of(context).pop(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galeri'),
                onTap: () {
                  Navigator.of(context).pop(ImageSource.gallery);
                },
              ),
            ],
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
    );

    if (!mounted) return;

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
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
        Navigator.pop(context, true); // Aman karena sudah cek mounted
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
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Buat Lelang', showBackButton: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Informasi Lelang',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            labelText: 'Judul Lelang',
                            prefixIcon: Icon(Icons.title),
                            border: OutlineInputBorder(),
                            hintText: 'Masukkan judul lelang',
                          ),
                          validator: _validateTitle,
                          textCapitalization: TextCapitalization.words,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _descController,
                          decoration: const InputDecoration(
                            labelText: 'Deskripsi',
                            prefixIcon: Icon(Icons.description),
                            border: OutlineInputBorder(),
                            hintText: 'Deskripsikan item yang akan dilelang',
                          ),
                          validator: _validateDescription,
                          maxLines: 3,
                          textCapitalization: TextCapitalization.sentences,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _priceController,
                          decoration: const InputDecoration(
                            labelText: 'Harga Awal (Rp)',
                            prefixIcon: Icon(Icons.monetization_on),
                            border: OutlineInputBorder(),
                            hintText: 'Contoh: 100000',
                          ),
                          keyboardType: TextInputType.number,
                          validator: _validatePrice,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        ),
                        const SizedBox(height: 16),
                        InkWell(
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
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Gagal menyimpan lokasi: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Lokasi',
                              prefixIcon: const Icon(Icons.location_on),
                              border: const OutlineInputBorder(),
                              errorText: _validateLocationId(
                                _locationIdController.text,
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _selectedLocationAddress ??
                                        'Pilih lokasi di peta',
                                    style: TextStyle(
                                      color:
                                          _selectedLocationAddress == null
                                              ? Colors.grey
                                              : null,
                                    ),
                                  ),
                                ),
                                const Icon(Icons.map),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _deadlineController,
                          decoration: const InputDecoration(
                            labelText: 'Deadline',
                            prefixIcon: Icon(Icons.schedule),
                            border: OutlineInputBorder(),
                            hintText: 'Pilih tanggal dan waktu deadline',
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          validator: _validateDeadline,
                          readOnly: true,
                          onTap: _selectDeadline,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Gambar Produk',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        if (_image != null) ...[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              _image!,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _pickImage,
                            icon: const Icon(Icons.image),
                            label: Text(
                              _image == null ? 'Pilih Gambar' : 'Ganti Gambar',
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child:
                        _isLoading
                            ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                            : const Text(
                              'Buat Lelang',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
