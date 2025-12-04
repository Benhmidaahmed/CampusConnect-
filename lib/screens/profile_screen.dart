import 'package:cc/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';
import '../widgets/profile/profile_header.dart';
import '../widgets/profile/profile_stats.dart';
import '../widgets/profile/profile_actions.dart';
import '../widgets/profile/publications_list.dart'; // ✅ CORRECT
import '../widgets/common/bottom_options_menu.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

// Le reste du code reste identique...

class _ProfileScreenState extends State<ProfileScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UserService _userService = UserService();

  Future<void> _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
            (Route<dynamic> route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la déconnexion: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0.0,
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Mon Profil',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => BottomOptionsMenu(
                  onEditProfile: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const EditProfileScreen(),
                      ),
                    );
                  },
                  onLogout: () {
                    Navigator.pop(context);
                    _signOut(context);
                  },
                ),
              );
            },
          ),
        ],
      ),
      body: currentUser == null
          ? const Center(child: Text("Aucun utilisateur connecté."))
          : StreamBuilder<AppUser>(
        stream: _userService.getCurrentUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return const Center(child: Text("Erreur de chargement du profil."));
          }

          final user = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),

                // Header avec avatar et infos
                ProfileHeader(user: user),
                const SizedBox(height: 16),

                // Statistiques
                StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection('publications')
                      .where('authorId', isEqualTo: currentUser!.uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    int publicationCount = 0;
                    int totalLikes = 0;

                    if (snapshot.hasData) {
                      publicationCount = snapshot.data!.docs.length;
                      for (final doc in snapshot.data!.docs) {
                        final data = doc.data() as Map<String, dynamic>;
                        totalLikes += (data['likes'] ?? 0) as int;
                      }
                    }

                    return ProfileStats(
                      publications: publicationCount,
                      likes: totalLikes,
                      followers: 0, // À implémenter plus tard
                    );
                  },
                ),

                // Bio
                const SizedBox(height: 20),
                Text(
                  user.bio ?? '',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black54,
                    height: 1.5,
                  ),
                ),

                // Boutons d'action
                const SizedBox(height: 24),
                ProfileActions(
                  onEditProfile: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const EditProfileScreen(),
                      ),
                    );
                  },
                  onShareProfile: () {
                    // TODO: Implement share profile
                  },
                ),

                // Publications
                const SizedBox(height: 32),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Mes Publications',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Utilisation du widget spécifique pour le profil
                ProfilePublicationsList(
                  firestore: _firestore,
                  userId: currentUser!.uid,
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}