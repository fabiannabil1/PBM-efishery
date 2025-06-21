import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/role_change_provider.dart';

class RequestRoleChangeDialog extends StatefulWidget {
  const RequestRoleChangeDialog({super.key});

  @override
  State<RequestRoleChangeDialog> createState() =>
      _RequestRoleChangeDialogState();
}

class _RequestRoleChangeDialogState extends State<RequestRoleChangeDialog> {
  final TextEditingController _reasonController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RoleChangeProvider>(
      builder: (context, provider, child) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.upgrade, color: Colors.blue, size: 28),
              const SizedBox(width: 8),
              const Text(
                'Upgrade ke Mitra',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Dengan menjadi mitra, Anda dapat:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                const Text(
                  '• Menjual produk di marketplace\n'
                  '• Mengikuti lelang sebagai penjual\n'
                  '• Akses fitur bisnis lainnya',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Alasan pengajuan (opsional):',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _reasonController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Jelaskan alasan Anda ingin menjadi mitra...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
                if (provider.errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.red.shade600,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            provider.errorMessage!,
                            style: TextStyle(
                              color: Colors.red.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed:
                  provider.isLoading
                      ? null
                      : () {
                        Navigator.of(context).pop();
                      },
              child: const Text('Batal', style: TextStyle(fontSize: 16)),
            ),
            ElevatedButton(
              onPressed:
                  provider.isLoading
                      ? null
                      : () async {
                        if (_formKey.currentState!.validate()) {
                          final success = await provider.requestRoleChange(
                            _reasonController.text.trim(),
                          );

                          if (success && mounted) {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Pengajuan berhasil dikirim!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        }
                      },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              child:
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
                      : const Text(
                        'Kirim Pengajuan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
            ),
          ],
        );
      },
    );
  }
}
