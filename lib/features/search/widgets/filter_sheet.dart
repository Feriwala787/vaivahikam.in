import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../providers/app_providers.dart';
import '../../../models/match_filter.dart';

class FilterSheet extends ConsumerStatefulWidget {
  const FilterSheet({super.key});

  @override
  ConsumerState<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends ConsumerState<FilterSheet> {
  late String? _gender, _religion, _caste, _manglik, _education, _profession, _income, _diet, _maritalStatus, _state;
  late String? _familyValues, _socialCircle, _personality, _lifeGoals, _politicalView, _religiousLevel, _livingPref;
  late RangeValues _ageRange, _heightRange;

  @override
  void initState() {
    super.initState();
    final f = ref.read(matchFilterProvider);
    _gender = f.gender;
    _religion = f.religion;
    _caste = f.caste;
    _manglik = f.manglik;
    _education = f.education;
    _profession = f.profession;
    _income = f.income;
    _diet = f.diet;
    _maritalStatus = f.maritalStatus;
    _state = f.state;
    _familyValues = null;
    _socialCircle = null;
    _personality = null;
    _lifeGoals = null;
    _politicalView = null;
    _religiousLevel = null;
    _livingPref = null;
    _ageRange = RangeValues((f.ageMin ?? 18).toDouble(), (f.ageMax ?? 45).toDouble());
    _heightRange = RangeValues((f.heightMin ?? 140).toDouble(), (f.heightMax ?? 200).toDouble());
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85, maxChildSize: 0.95, minChildSize: 0.5, expand: false,
      builder: (_, controller) => Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(controller: controller, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Advanced Filters', style: Theme.of(context).textTheme.titleLarge),
            TextButton(onPressed: _clearAll, child: const Text('Clear All')),
          ]),
          const Divider(),

          // === HARD FILTERS ===
          _header('Core Filters'),
          _dd('Gender', _gender, ['Male', 'Female'], (v) => setState(() => _gender = v)),
          _range('Age', _ageRange, 18, 60, (v) => setState(() => _ageRange = v)),
          _range('Height (cm)', _heightRange, 140, 200, (v) => setState(() => _heightRange = v)),
          _dd('Religion', _religion, AppConstants.religions, (v) => setState(() => _religion = v)),
          _dd('Caste', _caste, AppConstants.hinduCastes, (v) => setState(() => _caste = v)),
          _dd('Manglik', _manglik, AppConstants.manglikOptions, (v) => setState(() => _manglik = v)),
          _dd('Marital Status', _maritalStatus, AppConstants.maritalStatuses, (v) => setState(() => _maritalStatus = v)),

          // === ECONOMIC ===
          _header('Economic'),
          _dd('Education', _education, AppConstants.educationLevels, (v) => setState(() => _education = v)),
          _dd('Profession', _profession, AppConstants.professions, (v) => setState(() => _profession = v)),
          _dd('Income', _income, AppConstants.incomeRanges, (v) => setState(() => _income = v)),

          // === SOCIAL ===
          _header('Social & Values'),
          _dd('State', _state, AppConstants.states, (v) => setState(() => _state = v)),
          _dd('Diet', _diet, AppConstants.dietOptions, (v) => setState(() => _diet = v)),
          _dd('Family Values', _familyValues, AppConstants.familyValuesOptions, (v) => setState(() => _familyValues = v)),
          _dd('Social Circle', _socialCircle, AppConstants.socialCircles, (v) => setState(() => _socialCircle = v)),
          _dd('Living Preference', _livingPref, AppConstants.livingPreferences, (v) => setState(() => _livingPref = v)),

          // === PSYCHOLOGICAL ===
          _header('Personality & Mindset'),
          _dd('Personality', _personality, AppConstants.personalities, (v) => setState(() => _personality = v)),
          _dd('Life Goals', _lifeGoals, AppConstants.lifeGoalOptions, (v) => setState(() => _lifeGoals = v)),
          _dd('Political View', _politicalView, AppConstants.politicalViews, (v) => setState(() => _politicalView = v)),
          _dd('Religious Level', _religiousLevel, AppConstants.religiousLevels, (v) => setState(() => _religiousLevel = v)),

          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _applyFilters,
            child: const Padding(padding: EdgeInsets.all(14), child: Text('Apply Filters', style: TextStyle(fontSize: 16))),
          ),
        ]),
      ),
    );
  }

  Widget _header(String t) => Padding(padding: const EdgeInsets.only(top: 16, bottom: 8), child: Text(t, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)));

  Widget _dd(String label, String? value, List<String> options, ValueChanged<String?> onChanged) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: DropdownButtonFormField<String>(
      value: value, decoration: InputDecoration(labelText: label),
      items: [const DropdownMenuItem(value: null, child: Text('Any')), ...options.map((o) => DropdownMenuItem(value: o, child: Text(o)))],
      onChanged: onChanged,
    ));
  }

  Widget _range(String label, RangeValues range, double min, double max, ValueChanged<RangeValues> onChanged) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('$label: ${range.start.round()} - ${range.end.round()}'),
      RangeSlider(values: range, min: min, max: max, divisions: (max - min).round(),
        labels: RangeLabels('${range.start.round()}', '${range.end.round()}'), onChanged: onChanged),
    ]));
  }

  void _clearAll() => setState(() {
    _gender = _religion = _caste = _manglik = _education = _profession = _income = _diet = _maritalStatus = _state = null;
    _familyValues = _socialCircle = _personality = _lifeGoals = _politicalView = _religiousLevel = _livingPref = null;
    _ageRange = const RangeValues(18, 45);
    _heightRange = const RangeValues(140, 200);
  });

  void _applyFilters() {
    ref.read(matchFilterProvider.notifier).updateFilter(MatchFilter(
      gender: _gender, religion: _religion, caste: _caste, manglik: _manglik,
      education: _education, profession: _profession, income: _income,
      diet: _diet, maritalStatus: _maritalStatus, state: _state,
      ageMin: _ageRange.start.round(), ageMax: _ageRange.end.round(),
      heightMin: _heightRange.start.round(), heightMax: _heightRange.end.round(),
    ));
    Navigator.pop(context);
  }
}
