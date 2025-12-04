import 'package:flutter/material.dart';

class ProfileActions extends StatelessWidget {
  final VoidCallback onEditProfile;
  final VoidCallback onShareProfile;

  const ProfileActions({
    super.key,
    required this.onEditProfile,
    required this.onShareProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Bouton "Modifier le profil"
        Expanded(
          child: ElevatedButton(
            onPressed: onEditProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2590F4),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text(
              'Modifier le profil',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(width: 16),

        // Bouton "Partager"
        Expanded(
          child: OutlinedButton(
            onPressed: onShareProfile,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey.shade700,
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text(
              'Partager',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}