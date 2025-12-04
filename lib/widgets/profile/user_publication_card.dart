import 'package:flutter/material.dart';
import '../../models/publication.dart';

class UserPublicationCard extends StatelessWidget {
  final Publication publication;

  const UserPublicationCard({
    super.key,
    required this.publication,
  });

  bool isImageFile(String? fileName) {
    if (fileName == null) return false;
    final imageExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp'];
    final lowerFileName = fileName.toLowerCase();
    return imageExtensions.any((ext) => lowerFileName.endsWith(ext));
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

  @override
  Widget build(BuildContext context) {
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
          // Contenu
          if (publication.content.isNotEmpty)
            Column(
              children: [
                Text(
                  publication.content,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),

          // Image
          if (publication.fileUrl != null &&
              publication.fileName != null &&
              isImageFile(publication.fileName))
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
                      publication.fileUrl!,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
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

          // Fichier
          if (publication.fileUrl != null &&
              publication.fileName != null &&
              !isImageFile(publication.fileName))
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
                          publication.fileName!,
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

          // Statistiques et date seulement (PAS de boutons d'action)
          Row(
            children: [
              Row(
                children: [
                  const Icon(Icons.favorite_outline, size: 18, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    publication.likes.toString(),
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
                    publication.comments.toString(),
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                _formatTimeAgo(publication.timestamp),
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
          // NOTE: Pas de boutons Modifier/Supprimer pour les autres utilisateurs
        ],
      ),
    );
  }
}