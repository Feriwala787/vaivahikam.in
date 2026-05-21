import 'package:flutter/material.dart';
import '../../../models/profile.dart';

class SmartMatchCard extends StatelessWidget {
  final Profile profile;

  const SmartMatchCard({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(25), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(children: [
            Container(
              width: 60, height: 60,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.grey[200]),
              child: profile.photosUrl.isNotEmpty
                  ? ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(profile.photosUrl.first, fit: BoxFit.cover))
                  : const Icon(Icons.person, size: 30),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${profile.age} yrs, ${profile.height} cm', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text('${profile.caste} • ${profile.religion}', style: TextStyle(color: Colors.grey[600])),
            ])),
          ]),
          const Divider(height: 24),
          // Stats grid
          _statRow('Education', profile.education),
          _statRow('Profession', profile.profession),
          _statRow('Income', profile.income),
          _statRow('City', '${profile.city}, ${profile.state}'),
          _statRow('Family', profile.familyType),
          _statRow('Manglik', profile.manglik),
          _statRow('Diet', profile.diet),
          if (profile.familyWealth != null) _statRow('Family Wealth', profile.familyWealth!),
          const Divider(height: 24),
          // Branding
          Text('Vaivahikam.in', style: TextStyle(color: Colors.grey[400], fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _statRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
      ]),
    );
  }
}
