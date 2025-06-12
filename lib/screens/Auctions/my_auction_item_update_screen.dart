// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:efishery/models/auction_item.dart';
import '../../providers/auction_provider.dart';
import '../../services/location_service.dart';
import '../../routes/app_routes.dart';
import 'package:efishery/widgets/custom_appbar.dart';
import 'package:efishery/widgets/continue_button.dart';

class MyAuctionUpdateScreen extends StatefulWidget {
  final AuctionItem item;

  const MyAuctionUpdateScreen({super.key, required this.item});

  @override
  State<MyAuctionUpdateScreen> createState() => _MyAuctionUpdateScreenState();
}

class _MyAuctionUpdateScreenState extends State<MyAuctionUpdateScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _startingPriceController;
  late TextEditingController _locationIdController;
  String? _selectedLocationAddress;
  late DateTime _deadline;

  AuctionProvider? _auctionProvider;
  bool _isLoading = false;
  bool _hasChanges = false;

  // Color constants
  static const _AppColors _colors = _AppColors();

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeProvider();
    _setupChangeListeners();
  }

  @override
  void dispose() {
    _disposeResources();
    super.dispose();
  }

  // Initialization methods
  void _initializeControllers() {
    final item = widget.item;
    _titleController = TextEditingController(text: item.title);
    _descriptionController = TextEditingController(text: item.description);
    _startingPriceController = TextEditingController(
      text: item.startingPrice.toString(),
    );
    _locationIdController = TextEditingController(
      text: item.locationId.toString(),
    );
    _deadline = item.deadline;
  }

  void _initializeProvider() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _auctionProvider = Provider.of<AuctionProvider>(context, listen: false);
      _auctionProvider?.startAutoRefresh();
    });
  }

  void _setupChangeListeners() {
    _titleController.addListener(_onFieldChanged);
    _descriptionController.addListener(_onFieldChanged);
    _startingPriceController.addListener(_onFieldChanged);
    _locationIdController.addListener(_onFieldChanged);
  }

  void _disposeResources() {
    _auctionProvider?.stopAutoRefresh();
    _titleController.dispose();
    _descriptionController.dispose();
    _startingPriceController.dispose();
    _locationIdController.dispose();
  }

  // Event handlers
  void _onFieldChanged() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
    }
  }

  void _onDeadlineChanged() {
    setState(() => _hasChanges = true);
  }

  // Validation methods
  String? _validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Judul wajib diisi';
    }
    if (value.trim().length < 3) {
      return 'Judul minimal 3 karakter';
    }
    return null;
  }

  String? _validateDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Deskripsi wajib diisi';
    }
    if (value.trim().length < 10) {
      return 'Deskripsi minimal 10 karakter';
    }
    return null;
  }

  String? _validatePrice(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Harga awal wajib diisi';
    }
    final price = double.tryParse(value.trim());
    if (price == null) {
      return 'Harga harus berupa angka';
    }
    if (price <= 0) {
      return 'Harga harus lebih dari 0';
    }
    return null;
  }

  String? _validateLocationId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'ID Lokasi wajib diisi';
    }
    final locationId = int.tryParse(value.trim());
    if (locationId == null) {
      return 'ID Lokasi harus berupa angka';
    }
    if (locationId <= 0) {
      return 'ID Lokasi harus lebih dari 0';
    }
    return null;
  }

  // Date/Time picker methods
  Future<void> _selectDateTime() async {
    final pickedDate = await _selectDate();
    if (pickedDate != null) {
      final pickedTime = await _selectTime();
      if (pickedTime != null) {
        setState(() {
          _deadline = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
        _onDeadlineChanged();
      }
    }
  }

  Future<DateTime?> _selectDate() {
    return showDatePicker(
      context: context,
      initialDate:
          _deadline.isAfter(DateTime.now()) ? _deadline : DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: _colors.primary),
          ),
          child: child!,
        );
      },
    );
  }

  Future<TimeOfDay?> _selectTime() {
    return showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_deadline),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: _colors.primary),
          ),
          child: child!,
        );
      },
    );
  }

  // Update auction method
  Future<void> _updateAuction() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final success = await _auctionProvider?.updateAuction(
        auctionId: widget.item.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        startingPrice: double.parse(_startingPriceController.text.trim()),
        deadline: _deadline,
        locationId: int.parse(_locationIdController.text.trim()),
      );

      if (success == true && mounted) {
        _showSnackBar('Lelang berhasil diperbarui', isSuccess: true);
        setState(() => _hasChanges = false);
        Navigator.pop(context, true); // Return true to indicate success
      } else {
        _showSnackBar('Gagal memperbarui lelang');
      }
    } catch (e) {
      debugPrint('Error updating auction: $e');
      if (mounted) {
        _showSnackBar('Terjadi kesalahan saat memperbarui lelang');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Helper methods
  void _showSnackBar(String message, {bool isSuccess = false}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                isSuccess ? Icons.check_circle : Icons.error,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: isSuccess ? Colors.green : Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;

    final shouldLeave = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'Batalkan Perubahan?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: const Text(
              'Anda memiliki perubahan yang belum disimpan. Yakin ingin keluar?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Tetap Di Sini'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Keluar'),
              ),
            ],
          ),
    );

    return shouldLeave ?? false;
  }

  // Widget builders
  Widget _buildHeroImage() {
    return Hero(
      tag: 'auction_image_${widget.item.id}',
      child: Container(
        width: double.infinity,
        height: 240,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.network(
            widget.item.imageUrl,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: Colors.grey[200],
                child: const Center(child: CircularProgressIndicator()),
              );
            },
            errorBuilder:
                (context, error, stackTrace) => Container(
                  color: Colors.grey[200],
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.broken_image, size: 48, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('Gambar tidak dapat dimuat'),
                      ],
                    ),
                  ),
                ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
    int maxLines = 1,
    Widget? suffixIcon,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        maxLines: maxLines,
        readOnly: readOnly,
        onTap: onTap,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: _colors.primary),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: _colors.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }

  Widget _buildDateTimeField() {
    return GestureDetector(
      onTap: _isLoading ? null : _selectDateTime,
      child: AbsorbPointer(
        child: _buildFormField(
          controller: TextEditingController(
            text: DateFormat('dd MMM yyyy, HH:mm').format(_deadline),
          ),
          label: 'Batas Waktu Lelang',
          validator: (value) {
            if (_deadline.isBefore(DateTime.now())) {
              return 'Batas waktu tidak boleh di masa lalu';
            }
            return null;
          },
          readOnly: true,
          suffixIcon: Icon(Icons.calendar_today, color: _colors.primary),
        ),
      ),
    );
  }

  Widget _buildUpdateButton() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 24),
      child: ContinueButton(
        isEnabled: !_isLoading && _hasChanges,
        onPressed: (!_isLoading && _hasChanges) ? _updateAuction : null,
        label: _isLoading ? 'Memperbarui...' : 'Perbarui Lelang',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: CustomAppBar(title: 'Perbarui Lelang', showBackButton: true),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeroImage(),
                      const SizedBox(height: 32),

                      // Form title
                      Text(
                        'Informasi Lelang',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: _colors.darkBlue,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Form fields
                      _buildFormField(
                        controller: _titleController,
                        label: 'Judul Lelang',
                        validator: _validateTitle,
                      ),

                      _buildFormField(
                        controller: _descriptionController,
                        label: 'Deskripsi Lelang',
                        validator: _validateDescription,
                        maxLines: 4,
                      ),

                      _buildFormField(
                        controller: _startingPriceController,
                        label: 'Harga Awal (Rp)',
                        validator: _validatePrice,
                        keyboardType: TextInputType.number,
                        suffixIcon: Icon(
                          Icons.attach_money,
                          color: _colors.primary,
                        ),
                      ),

                      _buildDateTimeField(),

                      InkWell(
                        onTap:
                            _isLoading
                                ? null
                                : () async {
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

                                      if (locationId != null && mounted) {
                                        setState(() {
                                          _locationIdController.text =
                                              locationId.toString();
                                          _selectedLocationAddress =
                                              result['address'];
                                          _hasChanges = true;
                                        });
                                      }
                                    } catch (e) {
                                      if (mounted) {
                                        _showSnackBar(
                                          'Gagal menyimpan lokasi: $e',
                                        );
                                      }
                                    }
                                  }
                                },
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Lokasi',
                            labelStyle: TextStyle(color: _colors.primary),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
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
                                    fontSize: 16,
                                    color:
                                        _selectedLocationAddress == null
                                            ? Colors.grey
                                            : null,
                                  ),
                                ),
                              ),
                              Icon(Icons.map, color: _colors.primary),
                            ],
                          ),
                        ),
                      ),

                      _buildUpdateButton(),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),

            // Loading overlay
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Colors.white),
                      SizedBox(height: 16),
                      Text(
                        'Memperbarui lelang...',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Color constants class
class _AppColors {
  const _AppColors();

  Color get darkBlue => const Color(0xFF1E3A8A);
  Color get secondary => const Color(0xFF2563EB);
  Color get primary => const Color(0xFF3B82F6);
  Color get lightBlue => const Color(0xFF60A5FA);
}
