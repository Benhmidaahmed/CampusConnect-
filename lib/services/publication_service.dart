// services/publication_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/comment.dart';
import '../models/publication.dart';

class PublicationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Toggle like on publication
  Future<void> toggleLike(String publicationId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final publicationRef = _firestore.collection('publications').doc(publicationId);

    return _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(publicationRef);
      if (!snapshot.exists) return;

      final data = snapshot.data()!;
      final likedBy = List<String>.from(data['likedBy'] ?? []);
      final isLiked = likedBy.contains(user.uid);

      if (isLiked) {
        // Unlike
        likedBy.remove(user.uid);
        transaction.update(publicationRef, {
          'likes': FieldValue.increment(-1),
          'likedBy': likedBy,
        });
      } else {
        // Like
        likedBy.add(user.uid);
        transaction.update(publicationRef, {
          'likes': FieldValue.increment(1),
          'likedBy': likedBy,
        });
      }
    });
  }

  // Add comment to publication
  Future<void> addComment(String publicationId, String content) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final comment = Comment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      authorId: user.uid,
      authorName: user.displayName ?? 'Utilisateur Anonyme',
      content: content,
      timestamp: DateTime.now(),
    );

    final publicationRef = _firestore.collection('publications').doc(publicationId);

    return _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(publicationRef);
      if (!snapshot.exists) return;

      // Get current comments
      final data = snapshot.data()!;
      final commentList = List<Map<String, dynamic>>.from(data['commentList'] ?? []);

      // Add new comment
      commentList.add(comment.toMap());

      // Update publication
      transaction.update(publicationRef, {
        'comments': FieldValue.increment(1),
        'commentList': commentList,
      });
    });
  }

  // Get comments stream for a publication
  Stream<List<Comment>> getComments(String publicationId) {
    return _firestore
        .collection('publications')
        .doc(publicationId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) return [];
      final data = snapshot.data()!;
      final commentList = data['commentList'] as List<dynamic>? ?? [];
      return commentList.map((commentData) {
        return Comment.fromMap(commentData as Map<String, dynamic>);
      }).toList();
    });
  }

  // Update publication content
  Future<void> updatePublication(String publicationId, String newContent) async {
    try {
      await _firestore.collection('publications').doc(publicationId).update({
        'content': newContent,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour de la publication: $e');
    }
  }

  // Delete publication only from Firestore (without file deletion)
  Future<void> deletePublication(String publicationId) async {
    try {
      await _firestore.collection('publications').doc(publicationId).delete();
    } catch (e) {
      throw Exception('Erreur lors de la suppression de la publication: $e');
    }
  }

  // Get publication by ID
  Future<Publication?> getPublicationById(String publicationId) async {
    try {
      final doc = await _firestore.collection('publications').doc(publicationId).get();
      if (doc.exists) {
        return Publication.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Erreur lors de la récupération de la publication: $e');
    }
  }

  // Check if user is the author of the publication
  bool isUserAuthor(String publicationAuthorId) {
    final user = _auth.currentUser;
    return user != null && user.uid == publicationAuthorId;
  }
}