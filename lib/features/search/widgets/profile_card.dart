import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../models/profile.dart';

class ProfileCard extends StatelessWidget {
  final Profile profile;
  final VoidCallback onTap;

  const ProfileCard({super.key, required this.profile, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Blurred photo
            Expanded(
              flex: 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  profile.photosUrl.isNotEmpty
                      ? Image.network(profile.photosUrl.first, fit: BoxFit.cover)
                      : Container(color: Colors.grey[300], child: const Icon(Icons.person, size: 48)),
                  // Blur overlay (until unlocked)
                  ClipRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        color: Colors.black.withOpacity(0.1),
                        child: const Center(
                          child: Icon(Icons.lock, color: Colors.white70, size: 28),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${profile.age} yrs, ${profile.height} cm',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 2),
                    Text(profile.caste, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    Text(profile.city, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(Icons.work, size: 12, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Expanded(child: Text(profile.profession, style: const TextStyle(fontSize: 11), overflow: TextOverflow.ellipsis)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
