// models/publication.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Publication {
  final String id;
  final String authorId;
  final String authorName;
  final String content;
  final DateTime timestamp;
  final DateTime? updatedAt;
  final String? fileUrl;
  final String? fileName;
  final double? fileSize;
  final int likes;
  final int comments;
  final List<String> likedBy;
  final List<Map<String, dynamic>> commentList;

  Publication({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.content,
    required this.timestamp,
    this.updatedAt,
    this.fileUrl,
    this.fileName,
    this.fileSize,
    required this.likes,
    required this.comments,
    required this.likedBy,
    required this.commentList,
  });

  factory Publication.fromMap(Map<String, dynamic> data, String id) {
    return Publication(
      id: id,
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? 'Utilisateur inconnu',
      content: data['content'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null ? (data['updatedAt'] as Timestamp).toDate() : null,
      fileUrl: data['fileUrl'],
      fileName: data['fileName'],
      fileSize: (data['fileSize'] ?? 0).toDouble(),
      likes: (data['likes'] ?? 0) as int,
      comments: (data['comments'] ?? 0) as int,
      likedBy: List<String>.from(data['likedBy'] ?? []),
      commentList: List<Map<String, dynamic>>.from(data['commentList'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'authorId': authorId,
      'authorName': authorName,
      'content': content,
      'timestamp': timestamp,
      'updatedAt': updatedAt,
      'fileUrl': fileUrl,
      'fileName': fileName,
      'fileSize': fileSize,
      'likes': likes,
      'comments': comments,
      'likedBy': likedBy,
      'commentList': commentList,
    };
  }

  bool isLikedBy(String userId) {
    return likedBy.contains(userId);
  }
}