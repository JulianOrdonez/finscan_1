class User {
  int? id;
  String email;
  String password;

  User({this.id, required this.email, required this.password});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'password': password,
    };
  }
  User copyWith({
    int? id,
    String? email,
    String? password
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      password: password ?? "",
    );
  }
}
