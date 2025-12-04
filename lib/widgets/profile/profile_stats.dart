import 'package:flutter/material.dart';

class ProfileStats extends StatelessWidget {
  final int publications;
  final int likes;
  final int followers;

  const ProfileStats({
    super.key,
    required this.publications,
    required this.likes,
    required this.followers,
  });

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStatItem(publications.toString(), 'Publications'),
        const SizedBox(width: 20),
        _buildStatItem(likes.toString(), 'J\'aime'),
        const SizedBox(width: 20),
        _buildStatItem(followers.toString(), 'Abonnés'),
      ],
    );
  }
}