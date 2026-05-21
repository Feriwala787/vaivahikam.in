import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/match_filter.dart';
import '../models/profile.dart';
import '../models/scout.dart';
import '../services/supabase_service.dart';
import '../services/backend_service.dart';
import '../services/image_service.dart';

final supabaseServiceProvider = Provider((_) => SupabaseService());
final backendServiceProvider = Provider((_) => BackendService());
final imageServiceProvider = Provider((_) => ImageService());

// Current scout
final currentScoutProvider = StateProvider<Scout?>((ref) => null);

// Filter state
final matchFilterProvider = StateNotifierProvider<MatchFilterNotifier, MatchFilter>(
  (ref) => MatchFilterNotifier(),
);

class MatchFilterNotifier extends StateNotifier<MatchFilter> {
  MatchFilterNotifier() : super(const MatchFilter());

  void updateFilter(MatchFilter filter) => state = filter;
  void clearFilters() => state = const MatchFilter();
  void setGender(String? v) => state = state.copyWith(gender: v);
  void setReligion(String? v) => state = state.copyWith(religion: v);
  void setCaste(String? v) => state = state.copyWith(caste: v);
  void setAgeRange(int? min, int? max) => state = state.copyWith(ageMin: min, ageMax: max);
  void setHeightRange(int? min, int? max) => state = state.copyWith(heightMin: min, heightMax: max);
  void setCity(String? v) => state = state.copyWith(city: v);
  void setState(String? v) => state = state.copyWith(state: v);
  void setManglik(String? v) => state = state.copyWith(manglik: v);
  void setIncome(String? v) => state = state.copyWith(income: v);
  void setEducation(String? v) => state = state.copyWith(education: v);
  void setProfession(String? v) => state = state.copyWith(profession: v);
  void setDiet(String? v) => state = state.copyWith(diet: v);
  void setMaritalStatus(String? v) => state = state.copyWith(maritalStatus: v);
}

// Search results
final searchResultsProvider = FutureProvider.family<List<Profile>, int>((ref, page) async {
  final service = ref.read(supabaseServiceProvider);
  final filter = ref.watch(matchFilterProvider);
  return service.searchProfiles(filter, page: page);
});
