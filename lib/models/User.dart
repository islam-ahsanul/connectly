class User {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final String profileImageUrl;
  final DateTime birthday;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber = '',
    this.profileImageUrl = '',
    required this.birthday,
  });

  // Method to create a User object from a map (useful when fetching data from Firestore)
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      profileImageUrl: map['profileImageUrl'] ?? '',
      birthday: DateTime.parse(map['birthday']),
    );
  }

  // Method to convert User object to a map (useful when sending data to Firestore)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      'birthday': birthday.toIso8601String(),
    };
  }
}
