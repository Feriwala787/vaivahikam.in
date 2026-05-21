import '../models/profile.dart';
import '../core/constants/app_constants.dart';

class MatchScore {
  final double total;
  final double social;
  final double economic;
  final double physical;
  final double psychological;
  final double political;
  final double cultural;
  final double lifestyle;
  final Map<String, String> breakdown;

  MatchScore({
    required this.total,
    required this.social,
    required this.economic,
    required this.physical,
    required this.psychological,
    required this.political,
    required this.cultural,
    required this.lifestyle,
    required this.breakdown,
  });
}

class MatchEngine {
  /// Compute compatibility score between two profiles (0-100)
  MatchScore computeScore(Profile seeker, Profile candidate) {
    final breakdown = <String, String>{};

    // Cultural (weight: 25) - Religion, Caste, Manglik, Gotra
    final cultural = _culturalScore(seeker, candidate, breakdown);

    // Economic (weight: 20) - Income, Family Wealth, Property, Education
    final economic = _economicScore(seeker, candidate, breakdown);

    // Social (weight: 18) - Family Values, Social Status, Living Preference
    final social = _socialScore(seeker, candidate, breakdown);

    // Physical (weight: 15) - Age, Height, Complexion, Body Type, Lifestyle
    final physical = _physicalScore(seeker, candidate, breakdown);

    // Psychological (weight: 12) - Personality, Temperament, Life Goals
    final psychological = _psychologicalScore(seeker, candidate, breakdown);

    // Political/Ideological (weight: 10) - Political View, Religious Level
    final political = _politicalScore(seeker, candidate, breakdown);

    // Lifestyle (weight: bonus) - Diet, Smoking, Drinking
    final lifestyle = _lifestyleScore(seeker, candidate, breakdown);

    // Weighted total
    final total = (cultural * 0.25) +
        (economic * 0.20) +
        (social * 0.18) +
        (physical * 0.15) +
        (psychological * 0.12) +
        (political * 0.10);

    // Preference match bonus (if candidate matches seeker's stated preferences)
    final prefBonus = _preferenceBonus(seeker, candidate);
    final finalScore = (total + prefBonus).clamp(0.0, 100.0);

    return MatchScore(
      total: finalScore,
      social: social,
      economic: economic,
      physical: physical,
      psychological: psychological,
      political: political,
      cultural: cultural,
      lifestyle: lifestyle,
      breakdown: breakdown,
    );
  }

  // ===== CULTURAL DIMENSION (25%) =====
  double _culturalScore(Profile seeker, Profile candidate, Map<String, String> b) {
    double score = 0;

    // Religion match (40% of cultural)
    if (seeker.religion == candidate.religion) {
      score += 40;
      b['Religion'] = '✓ Same religion';
    }

    // Caste match (30% of cultural)
    if (seeker.caste == candidate.caste) {
      score += 30;
      b['Caste'] = '✓ Same caste';
    } else if (seeker.religion == candidate.religion) {
      score += 10; // Same religion different caste
    }

    // Manglik compatibility (20% of cultural)
    if (seeker.manglik == candidate.manglik) {
      score += 20;
      b['Manglik'] = '✓ Compatible';
    } else if (seeker.manglik == "Don't Know" || candidate.manglik == "Don't Know") {
      score += 10;
    } else if (seeker.manglik == 'No' && candidate.manglik == 'Yes') {
      b['Manglik'] = '✗ Mismatch';
    }

    // Gotra check (10% of cultural) - should NOT match
    if (seeker.gotra != null && candidate.gotra != null) {
      if (seeker.gotra != candidate.gotra) {
        score += 10;
        b['Gotra'] = '✓ Different gotra';
      } else {
        b['Gotra'] = '✗ Same gotra (not allowed)';
      }
    } else {
      score += 5; // Unknown, neutral
    }

    return score;
  }

  // ===== ECONOMIC DIMENSION (20%) =====
  double _economicScore(Profile seeker, Profile candidate, Map<String, String> b) {
    double score = 0;

    // Income compatibility (35%)
    final incomeMatch = _rangeProximity(
      AppConstants.incomeRanges.indexOf(seeker.income),
      AppConstants.incomeRanges.indexOf(candidate.income),
      AppConstants.incomeRanges.length,
    );
    score += incomeMatch * 35;
    if (incomeMatch > 0.7) b['Income'] = '✓ Compatible range';

    // Education level (25%)
    final eduMatch = _rangeProximity(
      AppConstants.educationLevels.indexOf(seeker.education),
      AppConstants.educationLevels.indexOf(candidate.education),
      AppConstants.educationLevels.length,
    );
    score += eduMatch * 25;
    if (eduMatch > 0.7) b['Education'] = '✓ Compatible level';

    // Family wealth (20%)
    if (seeker.familyWealth != null && candidate.familyWealth != null) {
      final wealthMatch = _rangeProximity(
        AppConstants.familyWealthLevels.indexOf(seeker.familyWealth!),
        AppConstants.familyWealthLevels.indexOf(candidate.familyWealth!),
        AppConstants.familyWealthLevels.length,
      );
      score += wealthMatch * 20;
    } else {
      score += 10;
    }

    // Family income (20%)
    if (seeker.familyIncome != null && candidate.familyIncome != null) {
      final famIncMatch = _rangeProximity(
        AppConstants.familyIncomeRanges.indexOf(seeker.familyIncome!),
        AppConstants.familyIncomeRanges.indexOf(candidate.familyIncome!),
        AppConstants.familyIncomeRanges.length,
      );
      score += famIncMatch * 20;
    } else {
      score += 10;
    }

    return score;
  }

  // ===== SOCIAL DIMENSION (18%) =====
  double _socialScore(Profile seeker, Profile candidate, Map<String, String> b) {
    double score = 0;

    // Location (30%) - same city > same state > different
    if (seeker.city.toLowerCase() == candidate.city.toLowerCase()) {
      score += 30;
      b['Location'] = '✓ Same city';
    } else if (seeker.state == candidate.state) {
      score += 20;
      b['Location'] = '~ Same state';
    } else {
      score += 5;
    }

    // Family values (25%)
    if (seeker.familyValues != null && candidate.familyValues != null) {
      final valMatch = _rangeProximity(
        AppConstants.familyValuesOptions.indexOf(seeker.familyValues!),
        AppConstants.familyValuesOptions.indexOf(candidate.familyValues!),
        AppConstants.familyValuesOptions.length,
      );
      score += valMatch * 25;
      if (valMatch > 0.7) b['Family Values'] = '✓ Compatible';
    } else {
      score += 12;
    }

    // Social circle compatibility (25%)
    if (seeker.socialCircle != null && candidate.socialCircle != null) {
      final circleMatch = _rangeProximity(
        AppConstants.socialCircles.indexOf(seeker.socialCircle!),
        AppConstants.socialCircles.indexOf(candidate.socialCircle!),
        AppConstants.socialCircles.length,
      );
      score += circleMatch * 25;
      if (circleMatch > 0.7) b['Social Circle'] = '✓ Compatible mindset';
    } else {
      score += 12;
    }

    // Family type (20%)
    if (seeker.familyType == candidate.familyType) {
      score += 20;
      b['Family Type'] = '✓ Same type';
    } else {
      score += 8;
    }

    return score;
  }

  // ===== PHYSICAL DIMENSION (15%) =====
  double _physicalScore(Profile seeker, Profile candidate, Map<String, String> b) {
    double score = 0;

    // Age compatibility (35%) - ideal gap: 2-5 years for male older
    final ageDiff = (seeker.age - candidate.age).abs();
    if (ageDiff <= 3) {
      score += 35;
    } else if (ageDiff <= 5) {
      score += 28;
    } else if (ageDiff <= 8) {
      score += 18;
    } else {
      score += 5;
    }
    if (ageDiff <= 5) b['Age'] = '✓ Good age match';

    // Height compatibility (25%)
    final heightDiff = (seeker.height - candidate.height).abs();
    if (heightDiff <= 10) {
      score += 25;
    } else if (heightDiff <= 20) {
      score += 18;
    } else {
      score += 8;
    }

    // Body type (20%)
    if (seeker.bodyType != null && candidate.bodyType != null) {
      if (seeker.bodyType == candidate.bodyType) {
        score += 20;
      } else {
        score += 10;
      }
    } else {
      score += 10;
    }

    // Exercise habit (20%)
    if (seeker.exerciseHabit != null && candidate.exerciseHabit != null) {
      final exMatch = _rangeProximity(
        AppConstants.exerciseHabits.indexOf(seeker.exerciseHabit!),
        AppConstants.exerciseHabits.indexOf(candidate.exerciseHabit!),
        AppConstants.exerciseHabits.length,
      );
      score += exMatch * 20;
    } else {
      score += 10;
    }

    return score;
  }

  // ===== PSYCHOLOGICAL DIMENSION (12%) =====
  double _psychologicalScore(Profile seeker, Profile candidate, Map<String, String> b) {
    double score = 0;

    // Personality compatibility (35%)
    // Opposites attract: introvert+extrovert = good, same = also good
    if (seeker.personality != null && candidate.personality != null) {
      if (seeker.personality == candidate.personality) {
        score += 30; // Same personality
      } else if (seeker.personality == 'Ambivert' || candidate.personality == 'Ambivert') {
        score += 35; // Ambivert matches everyone well
      } else {
        score += 25; // Opposites can work
      }
      b['Personality'] = '✓ ${candidate.personality}';
    } else {
      score += 17;
    }

    // Life goals alignment (35%)
    if (seeker.lifeGoals != null && candidate.lifeGoals != null) {
      if (seeker.lifeGoals == candidate.lifeGoals) {
        score += 35;
        b['Life Goals'] = '✓ Aligned goals';
      } else if (seeker.lifeGoals == 'Balanced' || candidate.lifeGoals == 'Balanced') {
        score += 28;
      } else {
        score += 12;
      }
    } else {
      score += 17;
    }

    // Temperament (30%)
    if (seeker.temperament != null && candidate.temperament != null) {
      final tempMatch = _rangeProximity(
        AppConstants.temperaments.indexOf(seeker.temperament!),
        AppConstants.temperaments.indexOf(candidate.temperament!),
        AppConstants.temperaments.length,
      );
      score += tempMatch * 30;
    } else {
      score += 15;
    }

    return score;
  }

  // ===== POLITICAL/IDEOLOGICAL DIMENSION (10%) =====
  double _politicalScore(Profile seeker, Profile candidate, Map<String, String> b) {
    double score = 0;

    // Political view (50%)
    if (seeker.politicalView != null && candidate.politicalView != null) {
      final polMatch = _rangeProximity(
        AppConstants.politicalViews.indexOf(seeker.politicalView!),
        AppConstants.politicalViews.indexOf(candidate.politicalView!),
        AppConstants.politicalViews.length,
      );
      score += polMatch * 50;
      if (polMatch > 0.7) b['Political'] = '✓ Similar views';
    } else {
      score += 25;
    }

    // Religious level (50%)
    if (seeker.religiousLevel != null && candidate.religiousLevel != null) {
      final relMatch = _rangeProximity(
        AppConstants.religiousLevels.indexOf(seeker.religiousLevel!),
        AppConstants.religiousLevels.indexOf(candidate.religiousLevel!),
        AppConstants.religiousLevels.length,
      );
      score += relMatch * 50;
      if (relMatch > 0.7) b['Religious Level'] = '✓ Compatible';
    } else {
      score += 25;
    }

    return score;
  }

  // ===== LIFESTYLE DIMENSION (bonus) =====
  double _lifestyleScore(Profile seeker, Profile candidate, Map<String, String> b) {
    double score = 0;

    // Diet (40%)
    if (seeker.diet == candidate.diet) {
      score += 40;
      b['Diet'] = '✓ Same diet';
    } else {
      score += 10;
    }

    // Smoking (30%)
    if (seeker.smokingHabit != null && candidate.smokingHabit != null) {
      if (seeker.smokingHabit == candidate.smokingHabit) {
        score += 30;
      } else if (seeker.smokingHabit == 'Never' && candidate.smokingHabit != 'Never') {
        score += 5;
        b['Smoking'] = '✗ Mismatch';
      } else {
        score += 15;
      }
    } else {
      score += 15;
    }

    // Drinking (30%)
    if (seeker.drinkingHabit != null && candidate.drinkingHabit != null) {
      if (seeker.drinkingHabit == candidate.drinkingHabit) {
        score += 30;
      } else if (seeker.drinkingHabit == 'Never' && candidate.drinkingHabit == 'Regularly') {
        score += 5;
        b['Drinking'] = '✗ Mismatch';
      } else {
        score += 15;
      }
    } else {
      score += 15;
    }

    return score;
  }

  // ===== PREFERENCE BONUS (up to +15) =====
  double _preferenceBonus(Profile seeker, Profile candidate) {
    double bonus = 0;
    int checks = 0;
    int matches = 0;

    if (seeker.prefReligion != null) {
      checks++;
      if (seeker.prefReligion == candidate.religion) matches++;
    }
    if (seeker.prefCaste != null) {
      checks++;
      if (seeker.prefCaste == candidate.caste) matches++;
    }
    if (seeker.prefAgeMin != null && seeker.prefAgeMax != null) {
      checks++;
      if (candidate.age >= seeker.prefAgeMin! && candidate.age <= seeker.prefAgeMax!) matches++;
    }
    if (seeker.prefHeightMin != null && seeker.prefHeightMax != null) {
      checks++;
      if (candidate.height >= seeker.prefHeightMin! && candidate.height <= seeker.prefHeightMax!) matches++;
    }
    if (seeker.prefIncome != null) {
      checks++;
      if (seeker.prefIncome == candidate.income) matches++;
    }
    if (seeker.prefCity != null) {
      checks++;
      if (seeker.prefCity!.toLowerCase() == candidate.city.toLowerCase()) matches++;
    }
    if (seeker.prefDiet != null) {
      checks++;
      if (seeker.prefDiet == candidate.diet) matches++;
    }
    if (seeker.prefManglik != null) {
      checks++;
      if (seeker.prefManglik == candidate.manglik) matches++;
    }

    if (checks > 0) {
      bonus = (matches / checks) * 15;
    }

    return bonus;
  }

  // ===== UTILITY =====
  /// Returns 0.0-1.0 based on how close two ordinal values are
  double _rangeProximity(int a, int b, int total) {
    if (a < 0 || b < 0) return 0.5; // Unknown values
    final diff = (a - b).abs();
    final maxDiff = total - 1;
    if (maxDiff == 0) return 1.0;
    return 1.0 - (diff / maxDiff);
  }

  /// Sort profiles by match score
  List<MapEntry<Profile, MatchScore>> rankMatches(Profile seeker, List<Profile> candidates) {
    final scored = candidates.map((c) => MapEntry(c, computeScore(seeker, c))).toList();
    scored.sort((a, b) => b.value.total.compareTo(a.value.total));
    return scored;
  }
}
