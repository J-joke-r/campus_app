class User {
  final String userId;
  final String name;
  final String email;
  final String? profilePictureUrl; // Optional
  final List<String> clubsJoined; // List of club IDs
  final List<String> registeredEvents; // List of event IDs

  User({
    required this.userId,
    required this.name,
    required this.email,
    this.profilePictureUrl,
    this.clubsJoined = const [], 
    this.registeredEvents = const [],
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      userId: map['userId'],
      name: map['name'],
      email: map['email'],
      profilePictureUrl: map['profilePictureUrl'],
      clubsJoined: List<String>.from(map['clubsJoined'] ?? []), // Handle null or empty list
      registeredEvents: List<String>.from(map['registeredEvents'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'profilePictureUrl': profilePictureUrl,
      'clubsJoined': clubsJoined,
      'registeredEvents': registeredEvents,
    };
  }
}
