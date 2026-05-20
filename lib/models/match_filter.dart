class MatchFilter {
  final String? gender;
  final int? ageMin;
  final int? ageMax;
  final int? heightMin;
  final int? heightMax;
  final String? religion;
  final String? caste;
  final String? subCaste;
  final String? manglik;
  final String? education;
  final String? profession;
  final String? income;
  final String? diet;
  final String? maritalStatus;
  final String? familyType;
  final String? city;
  final String? state;
  final String? complexion;
  final String? bodyType;
  final String sortBy;
  final bool ascending;

  const MatchFilter({
    this.gender,
    this.ageMin,
    this.ageMax,
    this.heightMin,
    this.heightMax,
    this.religion,
    this.caste,
    this.subCaste,
    this.manglik,
    this.education,
    this.profession,
    this.income,
    this.diet,
    this.maritalStatus,
    this.familyType,
    this.city,
    this.state,
    this.complexion,
    this.bodyType,
    this.sortBy = 'created_at',
    this.ascending = false,
  });

  MatchFilter copyWith({
    String? gender,
    int? ageMin,
    int? ageMax,
    int? heightMin,
    int? heightMax,
    String? religion,
    String? caste,
    String? subCaste,
    String? manglik,
    String? education,
    String? profession,
    String? income,
    String? diet,
    String? maritalStatus,
    String? familyType,
    String? city,
    String? state,
    String? complexion,
    String? bodyType,
    String? sortBy,
    bool? ascending,
  }) => MatchFilter(
    gender: gender ?? this.gender,
    ageMin: ageMin ?? this.ageMin,
    ageMax: ageMax ?? this.ageMax,
    heightMin: heightMin ?? this.heightMin,
    heightMax: heightMax ?? this.heightMax,
    religion: religion ?? this.religion,
    caste: caste ?? this.caste,
    subCaste: subCaste ?? this.subCaste,
    manglik: manglik ?? this.manglik,
    education: education ?? this.education,
    profession: profession ?? this.profession,
    income: income ?? this.income,
    diet: diet ?? this.diet,
    maritalStatus: maritalStatus ?? this.maritalStatus,
    familyType: familyType ?? this.familyType,
    city: city ?? this.city,
    state: state ?? this.state,
    complexion: complexion ?? this.complexion,
    bodyType: bodyType ?? this.bodyType,
    sortBy: sortBy ?? this.sortBy,
    ascending: ascending ?? this.ascending,
  );

  MatchFilter clear() => const MatchFilter();

  bool get hasActiveFilters =>
      gender != null || ageMin != null || ageMax != null ||
      heightMin != null || heightMax != null || religion != null ||
      caste != null || manglik != null || education != null ||
      profession != null || income != null || city != null || state != null;
}
