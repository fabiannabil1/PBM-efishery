import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/continue_button.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _bioController = TextEditingController();
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    final profile =
        Provider.of<ProfileProvider>(context, listen: false).profile;
    if (profile != null) {
      _nameController.text = profile.name;
      _addressController.text = profile.address;
      _bioController.text = profile.bio ?? '';
    }
  }

  Future<void> _pickImage() async {
    try {
      final ImageSource? source = await _showImageSourceDialog();
      if (source == null) return;

      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal Mengambil Gambar: ${e.toString()}')),
      );
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
                const Text(
                  'Pilih Sumber Gamber',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.camera_alt, color: Colors.blue),
                  ),
                  title: const Text(
                    'Kamera',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text('Ambil foto langsung'),
                  onTap: () => Navigator.of(context).pop(ImageSource.camera),
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.photo_library, color: Colors.blue),
                  ),
                  title: const Text(
                    'Galeri',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text('Pilih dari galeri'),
                  onTap: () => Navigator.of(context).pop(ImageSource.gallery),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<ProfileProvider>(context, listen: false);
      await provider.updateProfile(
        name: _nameController.text,
        address: _addressController.text,
        bio: _bioController.text,
        imageFile: _selectedImage,
      );

      if (provider.errorMessage != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(provider.errorMessage!)));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile berhasil diperbarui')),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProfileProvider>(context);
    final profile = provider.profile;

    return Scaffold(
      appBar: const CustomAppBar(title: 'Edit Profil', showBackButton: true),
      body:
          provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _pickImage,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage:
                              _selectedImage != null
                                  ? FileImage(_selectedImage!)
                                  : (profile?.profilePicture != null
                                          ? NetworkImage(
                                            profile!.profilePicture!,
                                          )
                                          : null)
                                      as ImageProvider?,
                          child:
                              _selectedImage == null &&
                                      (profile?.profilePicture == null)
                                  ? const Icon(Icons.camera_alt, size: 30)
                                  : null,
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: 'Nama'),
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? 'Masukkan Nama'
                                    : null,
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(labelText: 'Alamat'),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _bioController,
                        decoration: const InputDecoration(labelText: 'Bio'),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 24),
                      ContinueButton(
                        isEnabled: true,
                        onPressed: _saveProfile,
                        label: 'Simpan Perubahan',
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
