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
  final String status;
  final String? bio;
  final DateTime createdAt;

  // Economic dimensions
  final String? familyWealth;
  final String? propertyOwned;
  final String? familyIncome;

  // Social dimensions
  final String? socialStatus;
  final String? familyValues;
  final String? livingPreference; // city/town/village
  final String? socialCircle; // conservative/moderate/liberal

  // Psychological dimensions
  final String? personality; // introvert/extrovert/ambivert
  final String? temperament; // calm/moderate/energetic
  final String? lifeGoals; // career/family/balanced
  final String? communicationStyle;

  // Political/Ideological
  final String? politicalView; // traditional/moderate/progressive
  final String? religiousLevel; // very religious/moderate/not religious

  // Physical/Lifestyle
  final String? exerciseHabit;
  final String? smokingHabit;
  final String? drinkingHabit;
  final String? disability;

  // Partner preferences (what they want)
  final int? prefAgeMin;
  final int? prefAgeMax;
  final int? prefHeightMin;
  final int? prefHeightMax;
  final String? prefReligion;
  final String? prefCaste;
  final String? prefEducation;
  final String? prefIncome;
  final String? prefCity;
  final String? prefState;
  final String? prefManglik;
  final String? prefDiet;
  final String? prefFamilyType;
  final String? prefComplexion;

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
    this.familyWealth,
    this.propertyOwned,
    this.familyIncome,
    this.socialStatus,
    this.familyValues,
    this.livingPreference,
    this.socialCircle,
    this.personality,
    this.temperament,
    this.lifeGoals,
    this.communicationStyle,
    this.politicalView,
    this.religiousLevel,
    this.exerciseHabit,
    this.smokingHabit,
    this.drinkingHabit,
    this.disability,
    this.prefAgeMin,
    this.prefAgeMax,
    this.prefHeightMin,
    this.prefHeightMax,
    this.prefReligion,
    this.prefCaste,
    this.prefEducation,
    this.prefIncome,
    this.prefCity,
    this.prefState,
    this.prefManglik,
    this.prefDiet,
    this.prefFamilyType,
    this.prefComplexion,
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
    familyWealth: json['family_wealth'],
    propertyOwned: json['property_owned'],
    familyIncome: json['family_income'],
    socialStatus: json['social_status'],
    familyValues: json['family_values'],
    livingPreference: json['living_preference'],
    socialCircle: json['social_circle'],
    personality: json['personality'],
    temperament: json['temperament'],
    lifeGoals: json['life_goals'],
    communicationStyle: json['communication_style'],
    politicalView: json['political_view'],
    religiousLevel: json['religious_level'],
    exerciseHabit: json['exercise_habit'],
    smokingHabit: json['smoking_habit'],
    drinkingHabit: json['drinking_habit'],
    disability: json['disability'],
    prefAgeMin: json['pref_age_min'],
    prefAgeMax: json['pref_age_max'],
    prefHeightMin: json['pref_height_min'],
    prefHeightMax: json['pref_height_max'],
    prefReligion: json['pref_religion'],
    prefCaste: json['pref_caste'],
    prefEducation: json['pref_education'],
    prefIncome: json['pref_income'],
    prefCity: json['pref_city'],
    prefState: json['pref_state'],
    prefManglik: json['pref_manglik'],
    prefDiet: json['pref_diet'],
    prefFamilyType: json['pref_family_type'],
    prefComplexion: json['pref_complexion'],
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
    'family_wealth': familyWealth,
    'property_owned': propertyOwned,
    'family_income': familyIncome,
    'social_status': socialStatus,
    'family_values': familyValues,
    'living_preference': livingPreference,
    'social_circle': socialCircle,
    'personality': personality,
    'temperament': temperament,
    'life_goals': lifeGoals,
    'communication_style': communicationStyle,
    'political_view': politicalView,
    'religious_level': religiousLevel,
    'exercise_habit': exerciseHabit,
    'smoking_habit': smokingHabit,
    'drinking_habit': drinkingHabit,
    'disability': disability,
    'pref_age_min': prefAgeMin,
    'pref_age_max': prefAgeMax,
    'pref_height_min': prefHeightMin,
    'pref_height_max': prefHeightMax,
    'pref_religion': prefReligion,
    'pref_caste': prefCaste,
    'pref_education': prefEducation,
    'pref_income': prefIncome,
    'pref_city': prefCity,
    'pref_state': prefState,
    'pref_manglik': prefManglik,
    'pref_diet': prefDiet,
    'pref_family_type': prefFamilyType,
    'pref_complexion': prefComplexion,
  };
}
