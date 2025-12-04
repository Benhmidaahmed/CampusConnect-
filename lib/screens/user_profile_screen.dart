import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';
import '../widgets/profile/profile_header.dart';
import '../widgets/profile/profile_stats.dart';
// SUPPRIMEZ ces lignes inutiles :
// import '../widgets/profile/profile_actions.dart'; // ❌ À SUPPRIMER
// import '../widgets/profile/publications_list.dart'; // ❌ À SUPPRIMER
// import '../widgets/profile/profile_header.dart'; // ❌ DUPLICATA
// import '../widgets/profile/profile_stats.dart'; // ❌ DUPLICATA
// AJOUTEZ ces imports :
import '../widgets/profile/user_profile_actions.dart'; // ✅
import '../widgets/profile/user_publications_list.dart'; // ✅

class UserProfileScreen extends StatefulWidget {
  final String userId;

  const UserProfileScreen({super.key, required this.userId});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

// Le reste du code reste identique...
class _UserProfileScreenState extends State<UserProfileScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UserService _userService = UserService();
  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0.0,
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Profil',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<AppUser>(
        stream: _userService.getUserById(widget.userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.hasError) {
            return const Center(child: Text("Utilisateur non trouvé."));
          }

          final user = snapshot.data!;
          final isCurrentUser = currentUser?.uid == user.uid;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),

                // Header du profil (RÉUTILISÉ)
                ProfileHeader(user: user),
                const SizedBox(height: 16),

                // Statistiques (RÉUTILISÉ avec StreamBuilder)
                StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection('publications')
                      .where('authorId', isEqualTo: widget.userId)
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
                      followers: 0, // À implémenter
                    );
                  },
                ),

                // Bio (direct dans le screen)
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

                // Boutons d'action (NOUVEAU widget)
                if (!isCurrentUser) ...[
                  const SizedBox(height: 24),
                  UserProfileActions(
                    onFollow: () {
                      // TODO: Implement follow user
                    },
                    onMessage: () {
                      // TODO: Implement message user
                    },
                  ),
                ],

                // Publications (widget modifié)
                const SizedBox(height: 32),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Publications',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Liste des publications (widget modifié)
                UserPublicationsList(
                  firestore: _firestore,
                  userId: widget.userId,
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