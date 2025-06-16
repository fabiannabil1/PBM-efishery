import 'package:intl/intl.dart';

class Profile {
  final int id;
  final String name;
  final String phone;
  final String role;
  final String address;
  final String? bio;
  final String? profilePicture;
  final DateTime createdAt;

  Profile({
    required this.id,
    required this.name,
    required this.phone,
    required this.role,
    required this.address,
    this.bio,
    this.profilePicture,
    required this.createdAt,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    final rawDate = json['created_at'];
    late DateTime createdAtParsed;

    try {
      createdAtParsed = DateTime.parse(rawDate); // coba ISO dulu
    } catch (_) {
      try {
        // Hapus "GMT" kalau ada
        final cleaned = rawDate.toString().replaceAll("GMT", "").trim();

        // Format yang benar untuk "Mon, 02 Jun 2025 23:36:13"
        final formatter = DateFormat("EEE, dd MMM yyyy HH:mm:ss", "en_US");
        createdAtParsed = formatter.parse(cleaned);
      } catch (e) {
        throw FormatException('Gagal parsing tanggal: $rawDate\n$e');
      }
    }

    return Profile(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      role: json['role'],
      address: json['address'] ?? '',
      bio: json['bio'],
      profilePicture: json['profile_picture'],
      createdAt: createdAtParsed,
    );
  }
}
