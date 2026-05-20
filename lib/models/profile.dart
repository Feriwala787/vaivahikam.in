class Profile {
  final String id;
  final String scoutId;
  final String name;
  final String gender;
  final int age;
  final int height; // in cm
  final String religion;
  final String caste;
  final String? subCaste;
  final String? gotra;
  final String manglik;
  final String education;
  final String profession;
  final String income;
  final String diet;
  final String maritalStatus;
  final String familyType;
  final String? fatherOccupation;
  final int? siblings;
  final String city;
  final String state;
  final String? complexion;
  final String? bodyType;
  final List<String> photosUrl;
  final String status; // Active, Married, Reported
  final String? bio;
  final DateTime createdAt;

  Profile({
    required this.id,
    required this.scoutId,
    required this.name,
    required this.gender,
    required this.age,
    required this.height,
    required this.religion,
    required this.caste,
    this.subCaste,
    this.gotra,
    required this.manglik,
    required this.education,
    required this.profession,
    required this.income,
    required this.diet,
    required this.maritalStatus,
    required this.familyType,
    this.fatherOccupation,
    this.siblings,
    required this.city,
    required this.state,
    this.complexion,
    this.bodyType,
    required this.photosUrl,
    this.status = 'Active',
    this.bio,
    required this.createdAt,
  });

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
    id: json['id'],
    scoutId: json['scout_id'],
    name: json['name'],
    gender: json['gender'],
    age: json['age'],
    height: json['height'],
    religion: json['religion'],
    caste: json['caste'],
    subCaste: json['sub_caste'],
    gotra: json['gotra'],
    manglik: json['manglik'],
    education: json['education'],
    profession: json['profession'],
    income: json['income'],
    diet: json['diet'],
    maritalStatus: json['marital_status'],
    familyType: json['family_type'],
    fatherOccupation: json['father_occupation'],
    siblings: json['siblings'],
    city: json['city'],
    state: json['state'],
    complexion: json['complexion'],
    bodyType: json['body_type'],
    photosUrl: List<String>.from(json['photos_url'] ?? []),
    status: json['status'] ?? 'Active',
    bio: json['bio'],
    createdAt: DateTime.parse(json['created_at']),
  );

  Map<String, dynamic> toJson() => {
    'scout_id': scoutId,
    'name': name,
    'gender': gender,
    'age': age,
    'height': height,
    'religion': religion,
    'caste': caste,
    'sub_caste': subCaste,
    'gotra': gotra,
    'manglik': manglik,
    'education': education,
    'profession': profession,
    'income': income,
    'diet': diet,
    'marital_status': maritalStatus,
    'family_type': familyType,
    'father_occupation': fatherOccupation,
    'siblings': siblings,
    'city': city,
    'state': state,
    'complexion': complexion,
    'body_type': bodyType,
    'photos_url': photosUrl,
    'status': status,
    'bio': bio,
  };
}
