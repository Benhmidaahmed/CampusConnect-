import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';

class UserProfileScreen extends StatefulWidget {
  final String userId;

  const UserProfileScreen({super.key, required this.userId});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

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
          onPressed: () {
            Navigator.pop(context);
          },
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
                // Profile Avatar
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
                // User Name
                Text(
                  user.displayName?.toUpperCase() ?? user.email.split('@').first.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                // User's Email and Major
                Text(
                  user.email,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
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
                const SizedBox(height: 8),
                // User Stats
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

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildStatItem(publicationCount.toString(), 'Publications'),
                        const SizedBox(width: 20),
                        _buildStatItem(totalLikes.toString(), 'J\'aime'),
                        const SizedBox(width: 20),
                        _buildStatItem('0', 'Abonnés'),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 20),
                // Bio Section
                Text(
                  user.bio ?? '',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black54,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                // Action Buttons
                if (!isCurrentUser)
                  Row(
                    children: [
                      // "Suivre" Button
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // TODO: Implement follow user
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2590F4),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text('Suivre', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // "Message" Button
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            // TODO: Implement message user
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.grey.shade700,
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text('Message', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 32),
                // "Publications" Header
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
                // User's Publications List
                _buildUserPublications(),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

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

  // Build the list of user's publications
  Widget _buildUserPublications() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('publications')
          .where('authorId', isEqualTo: widget.userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Erreur: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Column(
            children: [
              Icon(
                Icons.feed_outlined,
                size: 80,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 16),
              const Text(
                'Aucune publication',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Cet utilisateur n\'a pas encore partagé de publications.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          );
        }

        final publications = snapshot.data!.docs.map((doc) {
          return doc.data() as Map<String, dynamic>;
        }).toList();

        // Manual sorting by timestamp
        publications.sort((a, b) {
          final aTime = (a['timestamp'] as Timestamp).toDate();
          final bTime = (b['timestamp'] as Timestamp).toDate();
          return bTime.compareTo(aTime);
        });

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: publications.length,
          itemBuilder: (context, index) {
            return _buildPublicationCard(publications[index]);
          },
        );
      },
    );
  }

  // A widget for displaying a publication card
  Widget _buildPublicationCard(Map<String, dynamic> publication) {
    bool isImageFile(String? fileName) {
      if (fileName == null) return false;
      final imageExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp'];
      final lowerFileName = fileName.toLowerCase();
      return imageExtensions.any((ext) => lowerFileName.endsWith(ext));
    }

    final content = publication['content'] ?? '';
    final fileUrl = publication['fileUrl'];
    final fileName = publication['fileName'];
    final likes = (publication['likes'] ?? 0) as int;
    final comments = (publication['comments'] ?? 0) as int;
    final timestamp = (publication['timestamp'] as Timestamp).toDate();

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Publication content
          if (content.isNotEmpty)
            Column(
              children: [
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),

          // Image preview
          if (fileUrl != null && fileName != null && isImageFile(fileName))
            Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[100],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      fileUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.error_outline, color: Colors.grey),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),

          // File attachment
          if (fileUrl != null && fileName != null && !isImageFile(fileName))
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.description, color: Colors.blue, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          fileName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),

          // Publication stats and date
          Row(
            children: [
              Row(
                children: [
                  const Icon(Icons.favorite_outline, size: 18, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    likes.toString(),
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Row(
                children: [
                  const Icon(Icons.mode_comment_outlined, size: 18, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    comments.toString(),
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                _formatTimeAgo(timestamp),
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) return 'À l\'instant';
    if (difference.inMinutes < 60) return 'Il y a ${difference.inMinutes} min';
    if (difference.inHours < 24) return 'Il y a ${difference.inHours} h';
    if (difference.inDays < 7) return 'Il y a ${difference.inDays} j';

    return 'Le ${date.day}/${date.month}/${date.year}';
  }
}