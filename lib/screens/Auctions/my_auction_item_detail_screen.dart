import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:efishery/models/auction_item.dart';
import '../../providers/auction_provider.dart';
import 'package:efishery/widgets/custom-appbar.dart';
import 'package:efishery/widgets/continue_button.dart';

class MyAuctionDetailScreen extends StatefulWidget {
  final AuctionItem item;

  const MyAuctionDetailScreen({super.key, required this.item});

  @override
  State<MyAuctionDetailScreen> createState() => _MyAuctionDetailScreenState();
}

class _MyAuctionDetailScreenState extends State<MyAuctionDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _startingPriceController;
  late TextEditingController _locationIdController;
  late DateTime _deadline;
  AuctionProvider? _auctionProvider;

  bool isButtonEnabled = true;

  @override
  void initState() {
    super.initState();
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _auctionProvider = Provider.of<AuctionProvider>(context, listen: false);
      _auctionProvider?.startAutoRefresh();
    });
  }

  @override
  void dispose() {
    _auctionProvider?.stopAutoRefresh();
    _titleController.dispose();
    _descriptionController.dispose();
    _startingPriceController.dispose();
    _locationIdController.dispose();
    super.dispose();
  }

  Future<void> _updateItem() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isButtonEnabled = false);

    try {
      final updated = await _auctionProvider!.updateAuction(
        auctionId: widget.item.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        startingPrice: double.tryParse(_startingPriceController.text) ?? 0,
        deadline: _deadline,
        locationId: int.tryParse(_locationIdController.text) ?? 0,
      );

      if (updated) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Auction updated successfully")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Update failed: $e")));
      }
    } finally {
      setState(() => isButtonEnabled = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: CustomAppBar(title: widget.item.title, showBackButton: true),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Hero(
                  tag: 'auction_image_${widget.item.title}',
                  child: Container(
                    width: double.infinity,
                    height: 300,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Image.network(
                      widget.item.imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder:
                          (_, __, ___) => const Center(
                            child: Icon(Icons.broken_image, size: 80),
                          ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Judul Lelang',
                    border: OutlineInputBorder(),
                  ),
                  validator:
                      (val) =>
                          val == null || val.isEmpty
                              ? 'Judul wajib diisi'
                              : null,
                ),

                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'Deskripsi',
                    border: OutlineInputBorder(),
                  ),
                  validator:
                      (val) =>
                          val == null || val.isEmpty
                              ? 'Deskripsi wajib diisi'
                              : null,
                ),

                const SizedBox(height: 16),
                TextFormField(
                  controller: _startingPriceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Harga Awal',
                    border: OutlineInputBorder(),
                  ),
                  validator:
                      (val) =>
                          (double.tryParse(val ?? '') == null)
                              ? 'Harga harus berupa angka'
                              : null,
                ),

                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: _deadline,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(_deadline),
                      );
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
                      }
                    }
                  },
                  child: AbsorbPointer(
                    child: TextFormField(
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Tenggat',
                        border: OutlineInputBorder(),
                      ),
                      controller: TextEditingController(
                        text: DateFormat('dd MMM yyyy HH:mm').format(_deadline),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                TextFormField(
                  controller: _locationIdController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'ID Lokasi',
                    border: OutlineInputBorder(),
                  ),
                  validator:
                      (val) =>
                          (int.tryParse(val ?? '') == null)
                              ? 'Lokasi harus berupa angka'
                              : null,
                ),

                const SizedBox(height: 24),
                ContinueButton(
                  isEnabled: isButtonEnabled,
                  onPressed: isButtonEnabled ? _updateItem : null,
                  label: 'Perbarui Lelang',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
