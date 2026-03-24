class User {
  final String id;
  final String name;
  final String email;
  final String? token;
  final String? memberSince;
  final double? height;
  final double? weight;
  final double? bmi;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.token,
    this.memberSince,
    this.height,
    this.weight,
    this.bmi,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      token: json['token'],
      memberSince: json['member_since'],
      height: (json['height'] as num?)?.toDouble(),
      weight: (json['weight'] as num?)?.toDouble(),
      bmi: (json['bmi'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'token': token,
      'member_since': memberSince,
      'height': height,
      'weight': weight,
      'bmi': bmi,
    };
  }
}
