import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/publication.dart';
import 'user_publication_card.dart';

class UserPublicationsList extends StatelessWidget {
  final FirebaseFirestore firestore;
  final String userId;

  const UserPublicationsList({
    super.key,
    required this.firestore,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: firestore
          .collection('publications')
          .where('authorId', isEqualTo: userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
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
          return _buildEmptyState();
        }

        final publications = snapshot.data!.docs.map((doc) {
          return Publication.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        }).toList();

        publications.sort((a, b) => b.timestamp.compareTo(a.timestamp));

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: publications.length,
          itemBuilder: (context, index) {
            return UserPublicationCard(
              publication: publications[index],
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
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
}