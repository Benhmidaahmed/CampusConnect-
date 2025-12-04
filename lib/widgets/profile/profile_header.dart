import 'package:flutter/material.dart';
import '../../models/user_model.dart';

class ProfileHeader extends StatelessWidget {
  final AppUser user;

  const ProfileHeader({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Avatar
        CircleAvatar(
          radius: 50,
          backgroundColor: const Color(0xFF6A1B9A),
          backgroundImage: user.photoURL != null
              ? NetworkImage(user.photoURL!)
              : null,
          child: user.photoURL == null
              ? const Icon(
            Icons.person,
            size: 60,
            color: Colors.white,
          )
              : null,
        ),
        const SizedBox(height: 16),

        // Nom
        Text(
          user.displayName?.toUpperCase() ?? user.email.split('@').first.toUpperCase(),
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),

        // Email
        Text(
          user.email,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),

        // Filière
        if (user.major != null && user.major!.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            user.major!,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ],
    );
  }
}