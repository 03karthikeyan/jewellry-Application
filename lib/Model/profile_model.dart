class Profile {
  final String id;
  final String firstname;
  final String lastname;
  final String phone;
  final String email;
  final String gender;
  final String result;

  Profile({
    required this.id,
    required this.firstname,
    required this.lastname,
    required this.phone,
    required this.email,
    required this.gender,
    required this.result,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] ?? '',
      firstname: json['firstname'] ?? '',
      lastname: json['lastname'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      gender: json['gender'] ?? '',
      result: json['result'] ?? '',
    );
  }
}
