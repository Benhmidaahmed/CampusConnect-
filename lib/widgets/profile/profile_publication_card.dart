import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/publication.dart';

class ProfilePublicationCard extends StatefulWidget {
  final Publication publication;
  final FirebaseFirestore firestore;

  const ProfilePublicationCard({
    super.key,
    required this.publication,
    required this.firestore,
  });

  @override
  State<ProfilePublicationCard> createState() => _ProfilePublicationCardState();
}

class _ProfilePublicationCardState extends State<ProfilePublicationCard> {
  bool isImageFile(String? fileName) {
    if (fileName == null) return false;
    final imageExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp'];
    final lowerFileName = fileName.toLowerCase();
    return imageExtensions.any((ext) => lowerFileName.endsWith(ext));
  }

  void _showEditPublicationDialog() {
    TextEditingController contentController =
    TextEditingController(text: widget.publication.content);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Modifier la publication'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: contentController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Contenu',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                await _updatePublication(contentController.text);
                Navigator.pop(context);
              },
              child: const Text('Enregistrer'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updatePublication(String newContent) async {
    try {
      await widget.firestore
          .collection('publications')
          .doc(widget.publication.id)
          .update({
        'content': newContent,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Publication mise à jour avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la mise à jour: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmer la suppression'),
          content: const Text(
              'Êtes-vous sûr de vouloir supprimer cette publication ? Cette action est irréversible.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _deletePublication();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deletePublication() async {
    try {
      await widget.firestore
          .collection('publications')
          .doc(widget.publication.id)
          .delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Publication supprimée avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la suppression: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
          if (widget.publication.content.isNotEmpty)
            Column(
              children: [
                Text(
                  widget.publication.content,
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
          if (widget.publication.fileUrl != null &&
              widget.publication.fileName != null &&
              isImageFile(widget.publication.fileName))
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
                      widget.publication.fileUrl!,
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
          if (widget.publication.fileUrl != null &&
              widget.publication.fileName != null &&
              !isImageFile(widget.publication.fileName))
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
                          widget.publication.fileName!,
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

          // Statistiques et date
          Row(
            children: [
              Row(
                children: [
                  const Icon(Icons.favorite_outline, size: 18, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    widget.publication.likes.toString(),
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
                    widget.publication.comments.toString(),
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                _formatTimeAgo(widget.publication.timestamp),
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),

          // Boutons d'action (Modifier/Supprimer)
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Modifier
              ElevatedButton(
                onPressed: _showEditPublicationDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.edit, size: 16),
                    SizedBox(width: 4),
                    Text('Modifier'),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Supprimer
              ElevatedButton(
                onPressed: _showDeleteConfirmationDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.delete, size: 16),
                    SizedBox(width: 4),
                    Text('Supprimer'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}