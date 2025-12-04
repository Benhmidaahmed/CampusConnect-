import 'package:flutter/material.dart';

class UserProfileActions extends StatelessWidget {
  final VoidCallback onFollow;
  final VoidCallback onMessage;

  const UserProfileActions({
    super.key,
    required this.onFollow,
    required this.onMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Bouton "Suivre"
        Expanded(
          child: ElevatedButton(
            onPressed: onFollow,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2590F4),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text(
              'Suivre',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(width: 16),

        // Bouton "Message"
        Expanded(
          child: OutlinedButton(
            onPressed: onMessage,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey.shade700,
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text(
              'Message',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}