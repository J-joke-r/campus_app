class Club {
  final String clubId;
  final String name;
  final String description;
  final String? logoUrl;
  final String contactEmail;
  final List<dynamic> members;
  final String adminId;

  Club({
    required this.clubId,
    required this.name,
    required this.description,
    this.logoUrl,
    required this.contactEmail,
    required this.members,
    required this.adminId,
  });

  factory Club.fromMap(Map<String, dynamic> map) {
    return Club(
      clubId: map['clubId'],
      name: map['name'],
      description: map['description'],
      logoUrl: map['logoUrl'],
      contactEmail: map['contactEmail'],
      members: List<dynamic>.from(map['members'] ?? []),
      adminId: map['adminId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'clubId': clubId,
      'name': name,
      'description': description,
      'logoUrl': logoUrl,
      'contactEmail': contactEmail,
      'members': members,
      'adminId': adminId,
    };
  }
}

