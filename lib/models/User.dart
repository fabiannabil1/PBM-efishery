class User {
  final String name;
  final String phone;
  final String password;
  final String? address;
  final String  role;

  User({
    required this.name,
    required this.phone,
    required this.password,
    required this.role,
    this.address,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'password': password,
      'address': address,
      'role': role,
    };
  }
}
