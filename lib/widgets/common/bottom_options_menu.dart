import 'package:flutter/material.dart';

class BottomOptionsMenu extends StatelessWidget {
  final VoidCallback onEditProfile;
  final VoidCallback onLogout;

  const BottomOptionsMenu({
    super.key,
    required this.onEditProfile,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Modifier le profil'),
            onTap: onEditProfile,
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Déconnexion'),
            onTap: onLogout,
          ),
        ],
      ),
    );
  }
}