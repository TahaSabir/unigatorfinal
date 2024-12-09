// File: lib/model/university_model.dart

class University {
  final int rank;
  final String name;
  final List<String> programs;
  final List<String> campuses;
  final List<String> images;
  final Contact contact;
  final String feeStructure;
  final String minimumSSC;
  final String minimumHSC;
  int score = 0; // New field for scoring

  University({
    required this.rank,
    required this.name,
    required this.programs,
    required this.campuses,
    required this.images,
    required this.contact,
    required this.feeStructure,
    required this.minimumSSC,
    required this.minimumHSC,
  });

  factory University.fromJson(Map<String, dynamic> json) {
    return University(
      rank: json['rank'] ?? 0,
      name: json['name'] ?? '',
      programs: List<String>.from(json['programs'] ?? []),
      campuses: List<String>.from(json['campuses'] ?? []),
      images: List<String>.from(json['images'] ?? []),
      contact: Contact.fromJson(json['contact'] ?? {}),
      feeStructure: json['feeStructure']?.toString() ?? '',
      minimumSSC: json['minimumSSC']?.toString() ?? '',
      minimumHSC: json['minimumHSC']?.toString() ?? '',
    );
  }
}

class Contact {
  final String phone;
  final String email;
  final String website;

  Contact({
    required this.phone,
    required this.email,
    required this.website,
  });

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      website: json['website']?.toString() ?? '',
    );
  }
}
